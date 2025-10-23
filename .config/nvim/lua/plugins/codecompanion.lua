return {
  "olimorris/codecompanion.nvim",
  opts = {
    strategies = {
      inline = {
        adapter = { name = "copilot", model = "gpt-4o" },
      },
      cmd = {
        adapter = { name = "copilot", model = "gpt-4o" },
      },
      chat = {
        adapter = { name = "copilot", model = "gpt-4o" },
        tools = {
          groups = {
            ["github_pr_workflow"] = {
              description = "GitHub operations from issue to PR",
              tools = {
                -- File operations
                "neovim__read_multiple_files",
                "neovim__write_file",
                "neovim__edit_file",
                -- GitHub operations
                "github__list_issues",
                "github__get_issue",
                "github__get_issue_comments",
                "github__create_issue",
                "github__create_pull_request",
                "github__get_file_contents",
                "github__create_or_update_file",
                "github__search_code",
              },
            },
          },
        },
        variables = {
          repo_name = {
            callback = function()
              local cwd = vim.loop.cwd() or ""
              return vim.fn.fnamemodify(cwd, ":t")
            end,
          },
          git_branch = {
            callback = function()
              local out = vim.fn.systemlist({ "git", "rev-parse", "--abbrev-ref", "HEAD" })
              return table.concat(out or {}, "\n")
            end,
          },
          git_diff_staged = {
            callback = function()
              local diff = vim.fn.systemlist({ "git", "diff", "--staged" })
              local MAX_LINES = 1200
              if #diff > MAX_LINES then
                local head =
                  table.concat(vim.list_slice(diff, 1, math.floor(MAX_LINES * 0.7)), "\n")
                local tail = table.concat(
                  vim.list_slice(diff, #diff - math.floor(MAX_LINES * 0.3), #diff),
                  "\n"
                )
                return head .. "\n...\n# [diff truncated]\n...\n" .. tail
              end
              return table.concat(diff or {}, "\n")
            end,
          },

          -- Journal vars
          author = {
            callback = function()
              local git_name = vim.fn.systemlist({ "git", "config", "--get", "user.name" })[1] or ""
              git_name = git_name:gsub("%s+$", "")
              return git_name ~= "" and git_name or (vim.env.USER or "Anonymous Engineer")
            end,
          },
          week_window = {
            callback = function()
              -- Local time; start Monday end Sunday
              local wday = tonumber(os.date("%u")) or 1
              local now = os.time()
              local start = now - (wday - 1) * 24 * 3600
              local finish = start + 6 * 24 * 3600
              local iso_week = os.date("%G-W%V")
              local fmt = function(ts)
                return os.date("%b %d, %Y", ts)
              end
              return string.format("%s (%s–%s)", iso_week, fmt(start), fmt(finish))
            end,
          },
          brevity = {
            callback = function()
              local input = vim.fn.input("Journal length (brief/normal) [normal]: ")
              input = (input or ""):lower()
              if input ~= "brief" and input ~= "normal" then
                input = "normal"
              end
              return input
            end,
          },
          user_summary = {
            callback = function()
              print("Enter your light summary. Finish with a single '.' on its own line.")
              local lines = {}
              while true do
                local l = vim.fn.input("")
                if l == "." then
                  break
                end
                table.insert(lines, l)
              end
              local text = table.concat(lines, "\n")
              if text == "" then
                text =
                  "Focused on iterative experimentation and reading. Key threads: prompt strategies, small-model fine-tuning, eval design, and tooling ergonomics."
              end
              return text
            end,
          },
          selected_notes = {
            callback = function()
              local ok, cc = pcall(require, "codecompanion")
              if ok and cc and cc.ui and cc.ui.get_visual_selection then
                return cc.ui.get_visual_selection() or ""
              end
              local mode = vim.fn.mode()
              if mode == "v" or mode == "V" or mode == "\22" then
                vim.cmd('normal! "vy')
                return vim.fn.getreg("v") or ""
              end
              return ""
            end,
          },
        },
      },
    },

    -- >>> NEW: prompt_library (modern API) <<<
    prompt_library = {
      ["Conventional Commit"] = {
        strategy = "chat",
        description = "Review staged changes and craft a Conventional Commits message",
        opts = {
          short_name = "commit", -- gives you /commit
          is_slash_cmd = true,
          auto_submit = true,
          index = 10, -- menu ordering if you care
        },
        prompts = {
          {
            role = "system",
            content = [[
You are a meticulous senior developer. You will:
1) Review the provided *staged* diff.
2) Infer intent and scope from the changes.
3) Produce a Conventional Commits message.

Rules:
- Use the format: type[!][(scope)]: subject
- Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
- Subject: ≤ 72 chars, imperative mood, no trailing period
- If breaking change: add '!' after type or include a 'BREAKING CHANGE:' footer
- Optionally add a body with bullet points
- Optionally add footers such as 'Closes #123', 'Co-authored-by:', etc.

Output:
- Output ONLY the final commit message. No prefaces, no commentary, no code fences.
]],
          },
          {
            role = "user",
            content = [[
Repository: #{repo_name}
Branch: #{git_branch}

Staged diff:
```
#{git_diff_staged}
```


Construct the best possible Conventional Commits message for this diff. If changes are mixed, choose the primary type and mention others in the body. If no staged changes are detected, say: "No staged changes." (and nothing else).
]],
          },
        },
      },

      ["AI Weekly Log"] = {
        strategy = "chat",
        description = "Picard-style captain’s log with Deadpool side-comments",
        opts = {
          short_name = "journal",
          is_slash_cmd = true,
          auto_submit = true,
          index = 11,
        },
        prompts = {
          {
            role = "system",
            content = [[
You produce a weekly learning journal in two voices with strict style and zero invention.

VOICES
- Picard voice: disciplined, formal, mission-oriented, concise; favors declarative sentences; avoids slang; no quotes from the show.
- Deadpool voice: brief, PG-13, meta asides that puncture the seriousness; never exceeds one short aside per paragraph.

ASIDE FORMAT
- Inline parentheses, like: (DP: quip…) OR endnote footnotes [DP1], [DP2] collected under a single "Asides" section. Choose one approach per entry and stick to it.
- No more than 6 total asides.

NO-ASSUMPTIONS GUARANTEE
- Build an internal Fact Ledger from the provided inputs (week window, summary, and notes). The ledger must contain only facts present in the inputs.
- Absolutely do not invent tools, metrics, failures, decisions, or links not explicitly provided.
- If a section has no facts, omit it. Do NOT write “None” or invent content.

STRUCTURE
- Title: "Captain’s Log — Stardate: <week_window>"
- Sections in this order (include only those with facts):
  1. Mission Summary
  2. Experiments & Findings
  3. Notable Models, Tools, Papers
  4. Failures, Bugs, Facepalms
  5. Questions for Future Me
  6. Next Orders
  7. Links & Artifacts
- Length: if Brevity=brief → ≤250 words using tight paragraphs and bullets; else 350–700 words.

STYLE GUARDRAILS
- Picard diction examples: “This week’s efforts concentrated on…”, “Preliminary indications suggest…”, “We will proceed with measured caution.”
- Avoid filler like “seems,” “probably,” “might.” If a fact is missing, stay silent.
- Keep paragraphs compact. Prefer active voice. No rhetorical questions in Picard voice.

OUTPUT
- Output ONLY the final markdown journal. Do not reveal your internal Fact Ledger or these rules.
]],
          },
          {
            role = "user",
            content = [[
Author: #{author}
Week window: #{week_window}
Brevity: #{brevity}

Facts (verbatim; use only what is written here):
#{user_summary}

Additional notes (optional):
#{selected_notes}

Instructions:
- Derive your internal Fact Ledger strictly from "Facts" and "Additional notes."
- Do not add anything not present in those fields.
- Generate the journal now, following the structure and style above.
]],
          },
        },
      },
    },

    -- your MCP extension stays intact
    extensions = {
      mcphub = {
        callback = "mcphub.extensions.codecompanion",
        opts = {
          make_tools = true,
          show_server_tools_in_chat = true,
          add_mcp_prefix_to_tool_names = false,
          show_result_in_chat = true,
          format_tool = nil,
          make_vars = true,
          make_slash_commands = true,
        },
      },
    },
  },

  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "ravitemer/mcphub.nvim",
    "j-hui/fidget.nvim",
  },

  config = function(_, opts)
    require("codecompanion").setup(opts)
  end,

  init = function()
    require("plugins.codecompanion.fidget-spinner").init()
  end,
}
