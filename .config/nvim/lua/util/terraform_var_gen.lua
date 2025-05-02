local M = {}

local function extract_var_names(bufnr)
  local var_names = {}
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    for var_name in line:gmatch("var%.([%w_]+)") do
      var_names[var_name] = true
    end
  end
  return var_names
end

local function get_declared_variables(var_file_path)
  local declared = {}
  local f = io.open(var_file_path, "r")
  if not f then
    return declared
  end
  for line in f:lines() do
    local var_name = line:match('variable%s+"([%w_]+)"')
    if var_name then
      declared[var_name] = true
    end
  end
  f:close()
  return declared
end

local function append_variable_stubs(var_file_path, missing_vars)
  local f = io.open(var_file_path, "a")
  if not f then
    vim.notify("Could not open " .. var_file_path .. " for writing", vim.log.levels.ERROR)
    return
  end

  for var, _ in pairs(missing_vars) do
    f:write(
      ('\nvariable "%s" {\n  description = "TODO: describe %s"\n  type        = string\n}\n'):format(
        var,
        var
      )
    )
  end
  f:close()
end

function M.create_missing_variables()
  local bufnr = vim.api.nvim_get_current_buf()
  local file_path = vim.api.nvim_buf_get_name(bufnr)
  local dir = vim.fn.fnamemodify(file_path, ":h")
  local var_file_path = dir .. "/variables.tf"

  local used_vars = extract_var_names(bufnr)
  local declared_vars = get_declared_variables(var_file_path)

  local missing_vars = {}
  for var, _ in pairs(used_vars) do
    if not declared_vars[var] then
      missing_vars[var] = true
    end
  end

  if next(missing_vars) == nil then
    vim.notify("All variables are declared!", vim.log.levels.INFO)
    return
  end

  append_variable_stubs(var_file_path, missing_vars)
  vim.notify("Missing variables added to " .. var_file_path, vim.log.levels.INFO)
end

return M
