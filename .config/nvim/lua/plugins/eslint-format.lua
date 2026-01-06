return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      setup = {
        eslint = function()
          vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
              local client = vim.lsp.get_client_by_id(args.data.client_id)
              if client and client.name == "eslint" then
                vim.api.nvim_create_autocmd("BufWritePre", {
                  buffer = args.buf,
                  command = "EslintFixAll",
                })
              end
            end,
          })
        end,
      },
    },
  },
}
