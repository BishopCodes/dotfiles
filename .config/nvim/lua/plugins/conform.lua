return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    local function get_project_formatter()
      local root = vim.fn.getcwd()

      local has_eslint = vim.fn.filereadable(root .. "/.eslintrc.json") == 1
        or vim.fn.filereadable(root .. "/.eslintrc.js") == 1
        or vim.fn.filereadable(root .. "/.eslintrc.cjs") == 1
        or vim.fn.filereadable(root .. "/.eslintrc") == 1
      local has_prettier = vim.fn.filereadable(root .. "/.prettierrc") == 1
        or vim.fn.filereadable(root .. "/.prettierrc.json") == 1
        or vim.fn.filereadable(root .. "/.prettierrc.js") == 1

      local has_biome = vim.fn.filereadable(root .. "/biome.json") == 1

      if has_biome then
        return "biome"
      end
      if has_prettier then
        return "prettier"
      end
      if has_eslint then
        return "eslint"
      end
      return nil
    end

    local formatter = get_project_formatter()

    opts.formatters_by_ft = opts.formatters_by_ft or {}

    if formatter == "eslint" then
      -- For ESLint projects, disable conform formatting (use EslintFixAll instead)
      opts.formatters_by_ft.javascript = {}
      opts.formatters_by_ft.typescript = {}
      opts.formatters_by_ft.javascriptreact = {}
      opts.formatters_by_ft.typescriptreact = {}
    elseif formatter == "prettier" then
      opts.formatters_by_ft.javascript = { "prettier" }
      opts.formatters_by_ft.typescript = { "prettier" }
      opts.formatters_by_ft.javascriptreact = { "prettier" }
      opts.formatters_by_ft.typescriptreact = { "prettier" }
    elseif formatter == "biome" then
      opts.formatters_by_ft.javascript = { "biome" }
      opts.formatters_by_ft.typescript = { "biome" }
      opts.formatters_by_ft.javascriptreact = { "biome" }
      opts.formatters_by_ft.typescriptreact = { "biome" }
    end

    return opts
  end,
}
