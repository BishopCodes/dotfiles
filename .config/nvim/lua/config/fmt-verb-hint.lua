-- fmt_verb_hint.lua
-- Format verb hint utility for Go printf statements
-- Place this file in your Neovim config directory, e.g., ~/.config/nvim/lua/custom/fmt_verb_hint.lua

-- Format verbs for different Go types
local format_map = {
  string = { "%s", "%q", "%x", "%X" },
  bool = { "%t" },
  int = { "%d", "%#x", "%b" },
  int8 = { "%d", "%#x", "%b" },
  int16 = { "%d", "%#x", "%b" },
  int32 = { "%d", "%#x", "%b" },
  int64 = { "%d", "%#x", "%b" },
  uint = { "%d", "%#x", "%b" },
  uint8 = { "%d", "%#x", "%b" },
  uint16 = { "%d", "%#x", "%b" },
  uint32 = { "%d", "%#x", "%b" },
  uint64 = { "%d", "%#x", "%b" },
  float32 = { "%f", "%.2f", "%g", "%e", "%E" },
  float64 = { "%f", "%.2f", "%g", "%e", "%E" },
  complex64 = { "%g", "%f", "%e" },
  complex128 = { "%g", "%f", "%e" },
  error = { "%v", "%+v" },
  interface = { "%v", "%T" },
  ["[]byte"] = { "%s", "%x", "% X" },
  pointer = { "%p", "%#p" },
  chan = { "%p" },
  struct = { "%v", "%+v", "%#v" },
}

-- Get the arguments of the printf-like function at the current cursor position
local function get_call_arguments()
  local node = vim.treesitter.get_node()
  if not node then
    return {}
  end

  -- Find the closest call_expression ancestor
  while node and node:type() ~= "call_expression" do
    node = node:parent()
  end

  if not node then
    return {}
  end

  -- Get the function name to ensure it's a printf-like function
  local func_node = node:field("function")[1]
  if not func_node then
    return {}
  end

  local func_name = vim.treesitter.get_node_text(func_node, 0)
  if not func_name:match(".*[D|W|P|S|L]?[Pp]rintf$") then
    return {}
  end

  -- Extract the arguments
  local args = {}
  local arguments_node = node:field("arguments")[1]

  if arguments_node then
    for i = 0, arguments_node:named_child_count() - 1 do
      local arg = arguments_node:named_child(i)
      table.insert(args, vim.treesitter.get_node_text(arg, 0))
    end
  end

  return args
end

-- Get the type of a Go symbol using LSP
local function get_type_of_symbol(symbol, bufnr, callback)
  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(bufnr, "textDocument/hover", params, function(err, result)
    if not err and result and result.contents then
      local content = result.contents.value or result.contents[1].value
      if not content then
        callback("interface") -- Default fallback
        return
      end

      local type_line = content:match("```go\n(.-)\n```")
      if type_line then
        local name, typename = type_line:match("([%w_]+) (%S+)")
        if name and typename then
          callback(typename)
        else
          callback("interface") -- Default fallback
        end
      else
        callback("interface") -- Default fallback
      end
    else
      callback("interface") -- Default fallback
    end
  end)
end

-- Show a floating window with format verb suggestions
local function show_hint(content)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)

  -- Calculate dimensions
  local width = 0
  for _, line in ipairs(content) do
    width = math.max(width, #line)
  end
  local height = #content

  -- Configure and open the floating window
  local opts = {
    style = "minimal",
    relative = "cursor",
    row = 1,
    col = 1,
    width = width + 2,
    height = height,
    border = "single",
  }

  local win = vim.api.nvim_open_win(buf, false, opts)

  -- Auto-close after 5 seconds
  vim.defer_fn(function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, 5000)

  -- Set background color
  vim.api.nvim_win_set_option(win, "winhl", "Normal:Normal")

  -- Make the window close on cursor move
  local group = vim.api.nvim_create_augroup("FmtVerbHintClose", { clear = true })
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave", "BufWinLeave" }, {
    group = group,
    buffer = 0,
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
        vim.api.nvim_del_augroup_by_id(group)
      end
    end,
  })
end

-- Main function to suggest format verbs
local function fmt_verb_hint()
  local args = get_call_arguments()
  if #args < 2 then
    vim.notify("No arguments found for format suggestion", vim.log.levels.WARN)
    return
  end

  local format_string = args[1]
  local format_args = { unpack(args, 2) }
  local results = { "Suggested format verbs:" }
  local remaining = #format_args

  for i, symbol in ipairs(format_args) do
    get_type_of_symbol(symbol, 0, function(typename)
      typename = typename:match("([%w%[%]]+)") or "interface"
      local suggestions = format_map[typename] or { "%v" }

      table.insert(
        results,
        string.format("%s (%s): %s", symbol, typename, table.concat(suggestions, ", "))
      )

      remaining = remaining - 1
      if remaining == 0 then
        show_hint(results)
      end
    end)
  end
end

-- Create the command
vim.api.nvim_create_user_command("FmtVerbHint", fmt_verb_hint, {})

-- Optional: Create a keymap (uncomment and modify as needed)
-- vim.keymap.set("n", "<leader>fh", fmt_verb_hint, { desc = "Show format verb hints" })

-- Return the module
return {
  fmt_verb_hint = fmt_verb_hint,
}
