-- Bitbucket Native MCP Server
-- Required environment variables (set before starting Neovim or via mcphub global_env):
--   BITBUCKET_USERNAME (Atlassian account email)
--   BITBUCKET_TOKEN (Atlassian API token)
--   BITBUCKET_WORKSPACE (default workspace slug)
--   BITBUCKET_BASE_URL (optional, default https://api.bitbucket.org/2.0)
-- Page size limited to 25 to avoid rate limiting.

local M = {}

local json_encode = vim.json.encode
local curl_ok, curl = pcall(require, "plenary.curl")

local function getenv(k)
  return (vim.env[k] and vim.env[k] ~= "") and vim.env[k] or nil
end

local function get_config()
  return {
    username = getenv("BITBUCKET_USERNAME"),
    token = getenv("BITBUCKET_TOKEN"),
    workspace = getenv("BITBUCKET_WORKSPACE"),
    base_url = getenv("BITBUCKET_BASE_URL") or "https://api.bitbucket.org/2.0",
    pagelen = 25,
  }
end

local function ensure_auth(res, cfg)
  if not (cfg.username and cfg.token) then
    return res:error("Missing BITBUCKET_USERNAME or BITBUCKET_TOKEN env vars")
  end
  if not cfg.workspace then
    return res:error("Missing BITBUCKET_WORKSPACE env var")
  end
  return true
end

local function is_debug()
  return getenv("BITBUCKET_DEBUG") == "1"
end

local function dbg(...)
  if not is_debug() then
    return
  end

  local parts = {}
  for i = 1, select("#", ...) do
    local v = select(i, ...)
    parts[#parts + 1] = type(v) == "table" and vim.inspect(v) or tostring(v)
  end
  local msg = "[bitbucket][debug] " .. table.concat(parts, " ")

  if vim and (type(vim.notify) ~= "function") then
    local ok, notify = pcall(require, "notify")
    if ok then
      vim.notify = notify
    end
  end

  if vim and type(vim.notify) == "function" and vim.log and vim.log.levels then
    vim.notify(msg, vim.log.levels.DEBUG, { title = "Bitbucket MCP" })
  elseif vim and vim.api and vim.api.nvim_echo then
    vim.api.nvim_echo({ { msg, "None" } }, true, {})
  else
    print(msg)
  end
end

local function short_err_body(body)
  if not body or body == "" then
    return ""
  end
  local s = body:gsub("%s+", " "):sub(1, 400)
  return s
end

local function basic_auth_header(cfg)
  local bit = require("bit") -- LuaJIT
  local function b64_encode_bit(s)
    if not s or s == "" then
      return ""
    end
    local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local out, i, len = {}, 1, #s
    while i <= len do
      local b1 = s:byte(i)
      i = i + 1
      local b2 = s:byte(i)
      i = i + 1
      local b3 = s:byte(i)
      i = i + 1
      local n = bit.bor(bit.lshift(b1, 16), bit.lshift((b2 or 0), 8), (b3 or 0))
      local c1 = bit.band(bit.rshift(n, 18), 0x3F) + 1
      local c2 = bit.band(bit.rshift(n, 12), 0x3F) + 1
      local c3 = bit.band(bit.rshift(n, 6), 0x3F) + 1
      local c4 = bit.band(n, 0x3F) + 1
      if not b2 then
        out[#out + 1] = alphabet:sub(c1, c1) .. alphabet:sub(c2, c2) .. "=="
      elseif not b3 then
        out[#out + 1] = alphabet:sub(c1, c1) .. alphabet:sub(c2, c2) .. alphabet:sub(c3, c3) .. "="
      else
        out[#out + 1] = alphabet:sub(c1, c1)
          .. alphabet:sub(c2, c2)
          .. alphabet:sub(c3, c3)
          .. alphabet:sub(c4, c4)
      end
    end
    return table.concat(out)
  end
  local credentials = cfg.username .. ":" .. cfg.token
  return "Basic " .. b64_encode_bit(credentials)
end

local function parse_header_block(hstr)
  local headers = {}
  for line in hstr:gmatch("[^\r\n]+") do
    local k, v = line:match("^([%w%-]+):%s*(.+)$")
    if k and v then
      local key = k:lower()
      if key == "authorization" then
        v = "***REDACTED***"
      end
      headers[key] = v
    end
  end
  return headers
end

local function http_get(path, query, cfg)
  local url = cfg.base_url .. path
  if query and next(query) then
    local qp = {}
    for k, v in pairs(query) do
      if v ~= nil and v ~= "" then
        qp[#qp + 1] = vim.fn.escape(k, " "):gsub(" ", "%%20")
          .. "="
          .. vim.fn.escape(tostring(v), " "):gsub(" ", "%%20")
      end
    end
    if #qp > 0 then
      url = url .. "?" .. table.concat(qp, "&")
    end
  end

  local headers = {
    Authorization = basic_auth_header(cfg),
    Accept = "application/json",
  }

  if is_debug() then
    dbg("GET", url)
    dbg("Headers:", "Authorization=***REDACTED***", "Accept=application/json")
    if query and next(query) then
      dbg("Query:", vim.inspect(query))
    end
  end

  if curl_ok then
    -- plenary.curl path
    local resp = curl.get({ url = url, headers = headers, compressed = true, redirect = true })
    local status = tonumber(resp.status) or 0
    local body = resp.body or ""
    local resp_headers = {}
    if resp.headers then
      -- plenary returns a table already; normalize keys to lowercase
      for k, v in pairs(resp.headers) do
        resp_headers[string.lower(k)] = v
      end
    end

    if is_debug() then
      dbg("Status:", status)
      local sample = body:sub(1, 600):gsub("%s+", " ")
      dbg("Body(sample):", sample)
      if resp_headers["x-request-id"] then
        dbg("X-Request-Id:", resp_headers["x-request-id"])
      end
      if resp_headers["x-ratelimit-remaining"] then
        dbg("RateLimit Remaining:", resp_headers["x-ratelimit-remaining"])
      end
      if resp_headers["www-authenticate"] then
        dbg("WWW-Authenticate:", resp_headers["www-authenticate"])
      end
    end

    return status, body, resp_headers
  else
    -- system curl path: capture headers and body separately
    local hdr_file = vim.fn.tempname()
    local body_file = vim.fn.tempname()
    local header_args =
      string.format('-H "Authorization: %s" -H "Accept: application/json"', headers.Authorization)
    local cmd = string.format(
      "curl -sS -L -D %s -o %s %s %s",
      vim.fn.shellescape(hdr_file),
      vim.fn.shellescape(body_file),
      header_args,
      vim.fn.shellescape(url)
    )
    local ok = vim.fn.system(cmd)
    local status_code = tonumber(
      vim.fn.system(
        string.format(
          "awk \"END{print}\" %s | sed -n 's/^.* \\([0-9][0-9][0-9]\\) .*$/\\1/p'",
          vim.fn.shellescape(hdr_file)
        )
      )
    ) or 0
    local body = vim.fn.readfile(body_file)
    body = table.concat(body, "\n")
    local hdr_str = table.concat(vim.fn.readfile(hdr_file), "\n")
    local resp_headers = parse_header_block(hdr_str)

    if is_debug() then
      dbg("Status:", status_code)
      local sample = (body or ""):sub(1, 600):gsub("%s+", " ")
      dbg("Body(sample):", sample)
      if resp_headers["x-request-id"] then
        dbg("X-Request-Id:", resp_headers["x-request-id"])
      end
      if resp_headers["x-ratelimit-remaining"] then
        dbg("RateLimit Remaining:", resp_headers["x-ratelimit-remaining"])
      end
      if resp_headers["www-authenticate"] then
        dbg("WWW-Authenticate:", resp_headers["www-authenticate"])
      end
    end

    return status_code, body, resp_headers
  end
end
local function send_json(res, tbl)
  return res:text(json_encode(tbl), "application/json"):send()
end

M = {
  name = "bitbucket",
  displayName = "Bitbucket",
  capabilities = {
    tools = {
      {
        name = "list_repositories",
        description = "List repositories in a workspace (paginated, pagelen=25)",
        inputSchema = {
          type = "object",
          properties = {
            workspace = {
              type = "string",
              description = "Workspace slug (defaults BITBUCKET_WORKSPACE)",
            },
            page = { type = "integer", description = "Page number (Bitbucket page param)" },
          },
        },
        handler = function(req, res)
          local cfg = get_config()
          if not ensure_auth(res, cfg) then
            return
          end
          local workspace = req.params.workspace or cfg.workspace
          local q = { pagelen = cfg.pagelen, page = req.params.page }
          local status, body = http_get("/repositories/" .. workspace, q, cfg)
          if status ~= 200 then
            return res:error("Bitbucket API error listing repositories")
          end
          return res:text(body, "application/json"):send()
        end,
      },
      {
        name = "search_repositories",
        description = 'Search repositories by name fragment (name~"query")',
        inputSchema = {
          type = "object",
          required = { "query" },
          properties = {
            query = { type = "string", description = "Substring to match in repository name" },
            workspace = {
              type = "string",
              description = "Workspace slug (defaults BITBUCKET_WORKSPACE)",
            },
            page = { type = "integer" },
          },
        },
        handler = function(req, res)
          local cfg = get_config()
          if not ensure_auth(res, cfg) then
            return
          end
          local workspace = req.params.workspace or cfg.workspace
          local q = {
            pagelen = cfg.pagelen,
            page = req.params.page,
            q = 'name~"' .. req.params.query .. '"',
          }
          local status, body = http_get("/repositories/" .. workspace, q, cfg)
          if status ~= 200 then
            return res:error("Bitbucket API error searching repositories")
          end
          return res:text(body, "application/json"):send()
        end,
      },
      {
        name = "get_repository",
        description = "Get metadata for a repository",
        inputSchema = {
          type = "object",
          required = { "repo" },
          properties = {
            repo = { type = "string", description = "Repository slug" },
            workspace = {
              type = "string",
              description = "Workspace slug (defaults BITBUCKET_WORKSPACE)",
            },
          },
        },
        handler = function(req, res)
          local cfg = get_config()
          if not ensure_auth(res, cfg) then
            return
          end
          local workspace = req.params.workspace or cfg.workspace
          local repo = req.params.repo
          local status, body = http_get("/repositories/" .. workspace .. "/" .. repo, nil, cfg)
          if status ~= 200 then
            return res:error("Bitbucket API error getting repository")
          end
          return res:text(body, "application/json"):send()
        end,
      },
      {
        name = "list_directory",
        description = "List directory contents in a repo at ref/path",
        inputSchema = {
          type = "object",
          required = { "repo" },
          properties = {
            repo = { type = "string", description = "Repository slug" },
            ref = { type = "string", description = "Commit/branch/tag (default HEAD)" },
            path = { type = "string", description = "Path inside repository (optional)" },
            workspace = { type = "string" },
            page = { type = "integer" },
          },
        },
        handler = function(req, res)
          local cfg = get_config()
          if not ensure_auth(res, cfg) then
            return
          end
          local workspace = req.params.workspace or cfg.workspace
          local ref = req.params.ref or "HEAD"
          local path = req.params.path or ""
          local q = { pagelen = cfg.pagelen, page = req.params.page }
          local api_path =
            string.format("/repositories/%s/%s/src/%s/%s", workspace, req.params.repo, ref, path)
          local status, body = http_get(api_path, q, cfg)
          if status ~= 200 then
            return res:error("Bitbucket API error listing directory")
          end
          return res:text(body, "application/json"):send()
        end,
      },
      {
        name = "get_file",
        description = "Get raw file content from repository at ref/path",
        inputSchema = {
          type = "object",
          required = { "repo", "path" },
          properties = {
            repo = { type = "string", description = "Repository slug" },
            path = { type = "string", description = "File path" },
            ref = { type = "string", description = "Commit/branch/tag (default HEAD)" },
            workspace = { type = "string" },
          },
        },
        handler = function(req, res)
          local cfg = get_config()
          if not ensure_auth(res, cfg) then
            return
          end
          local workspace = req.params.workspace or cfg.workspace
          local ref = req.params.ref or "HEAD"
          local api_path = string.format(
            "/repositories/%s/%s/src/%s/%s",
            workspace,
            req.params.repo,
            ref,
            req.params.path
          )
          local status, body = http_get(api_path, nil, cfg)
          if status ~= 200 then
            return res:error("Bitbucket API error getting file")
          end
          return res:text(body, "text/plain"):send()
        end,
      },
      {
        name = "debug_auth",
        description = "Check Bitbucket credentials against /user",
        inputSchema = { type = "object", properties = {} },
        handler = function(req, res)
          local cfg = get_config()
          if not (cfg.username or cfg.email) or not cfg.token then
            return res:error("Missing username/email or token")
          end
          local status, body, hdrs = http_get("/user", nil, cfg)
          if status ~= 200 then
            return res:error(
              string.format(
                "Auth failed [status=%s%s]\n%s",
                tostring(status),
                hdrs and (", request_id=" .. (hdrs["x-request-id"] or "n/a")) or "",
                short_err_body(body)
              )
            )
          end
          return res:text(body, "application/json"):send()
        end,
      },
    },
    resources = {
      {
        name = "repositories",
        uri = "bitbucket://repositories",
        description = "List first page of repositories for default workspace",
        handler = function(req, res)
          local cfg = get_config()
          if not ensure_auth(res, cfg) then
            return
          end
          local status, body =
            http_get("/repositories/" .. cfg.workspace, { pagelen = cfg.pagelen }, cfg)
          if status ~= 200 then
            return res:error(
              "Bitbucket API error listing repositories (status: "
                .. tostring(status)
                .. "): "
                .. tostring(body)
            )
          end
          return res:text(body, "application/json"):send()
        end,
      },
    },
    resourceTemplates = {
      {
        name = "file",
        uriTemplate = "bitbucket://{repo}/{ref}/src/{path*}",
        description = "Get raw file content from repo/ref",
        handler = function(req, res)
          local cfg = get_config()
          if not ensure_auth(res, cfg) then
            return
          end
          local repo = req.params.repo
          local ref = req.params.ref
          local path = req.params["path"] or ""
          local api_path =
            string.format("/repositories/%s/%s/src/%s/%s", cfg.workspace, repo, ref, path)
          local status, body = http_get(api_path, nil, cfg)
          if status ~= 200 then
            return res:error("Bitbucket API error getting file template")
          end
          return res:text(body, "text/plain"):send()
        end,
      },
    },
    prompts = {},
  },
}

return M
