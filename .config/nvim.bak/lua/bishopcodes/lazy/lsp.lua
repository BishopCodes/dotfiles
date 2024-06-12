return {
  {
    'williamboman/mason.nvim',
    lazy = true,
    config = function()
      require('mason').setup()
    end,
  },
  {
    'b0o/SchemaStore.nvim',
    lazy = true,
    version = false,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    config = function()
      require('mason-lspconfig').setup {
        ensure_installed = {
          -- https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
          'bashls',
          'omnisharp_mono',
          'clangd',
          'dockerls',
          'eslint',
          'htmx',
          'html',
          'helm_ls',
          'jsonls',
          'jdtls',
          'tsserver',
          'kotlin_language_server',
          'lua_ls',
          'marksman',
          'ocamllsp',
          --'jedi_language_server',
          'gopls',
          'pylsp',
          'rust_analyzer',
          'sqlls',
          'tailwindcss',
          'terraformls',
          'tflint',
          'zls',
        },
      }
    end,
    opts = {
      auto_install = true,
      jsonls = {
        -- lazy-load schemastore when needed
        on_new_config = function(new_config)
          new_config.settings.json.schemas = new_config.settings.json.schemas or {}
          vim.list_extend(new_config.settings.json.schemas, require('schemastore').json.schemas())
        end,
        settings = {
          json = {
            format = {
              enable = true,
            },
            validate = { enable = true },
          },
        },
      },
    },
  },
  { 'folke/neodev.nvim', opts = {} },
  {
    'neovim/nvim-lspconfig',
    lazy = true,
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local lspconfig = require 'lspconfig'
      lspconfig.lua_ls.setup {
        capabilities = capabilities,
        settings = {
          Lua = {
            format = {
              enable = true,
            },
            completion = {
              callSnippet = 'Replace',
            },
          },
        },
      }

      lspconfig.taplo.setup {
        capabilities = capabilities,
      }

      lspconfig.eslint.setup {
        capabilities = capabilities,
        root_dir = lspconfig.util.root_pattern('package.json', 'package-lock.json'),
        filetypes = {
          'typescript',
          'typescriptreact',
          'typescript.tsx',
          'javascript',
          'javascriptreact',
          'javascript.jsx',
        },
        single_file_support = true,
      }

      lspconfig.tsserver.setup {
        capabilities = capabilities,
      }

      local check_eslint_config = function(client)
        if client.name ~= 'eslint' and client.name ~= 'tsserver' then
          return false
        end
        return true
      end

      lspconfig.html.setup {
        capabilities = capabilities,
      }
      lspconfig.gopls.setup {
        cmd = { 'gopls', '--remote=auto' },
      }
      lspconfig.jdtls.setup {
        cmd = { 'jdtls' },
      }
      require('lspconfig').terraformls.setup {}
      -- Use LspAttach autocommand to only map the following keys
      -- after the language server attaches to the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          -- Enable completion triggered by <c-x><c-o>
          vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          local ts_builtin = require 'telescope.builtin'

          -- Buffer local mappings.
          -- See `:help vim.lsp.*` for documentation on any of the below functions
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = ev.buf, desc = '[G]o to [D]eclaration' })
          -- keymap go to definition
          vim.keymap.set('n', 'gtd', vim.lsp.buf.definition, { buffer = ev.buf, desc = '[G]o to [D]efinition' })
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
          vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
          vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
          vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts)
          vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
          vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)

          if client.name == 'lua_ls' then
            vim.keymap.set('n', '<leader>hc', ':help <C-R><C-W><CR>', { buffer = ev.buf, desc = '[H]elp under [C]ursor' })
          end

          local format_opt = { buffer = ev.buf, desc = '[F]ormat' }
          if check_eslint_config(client) then
            vim.keymap.set('n', '<leader>F', ':EslintFixAll<CR>', format_opt)
            vim.api.nvim_create_autocmd('BufWritePre', {
              buffer = ev.buf,
              command = ':EslintFixAll',
            })
          else
            vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, format_opt)
            vim.api.nvim_create_autocmd('BufWritePre', {
              buffer = ev.buf,
              command = 'lua vim.lsp.buf.format()',
            })
          end
        end,
      })
      vim.g.rustaceanvim = {
        server = {
          on_attach = function(_client, bufnr)
            vim.keymap.set({ 'n', 'v' }, '<leader>ca', ':RustLsp codeAction<CR>', { buffer = bufnr, desc = '[C]ode [A]ction' })
            vim.keymap.set('n', 'K', ':RustLsp hover actions<CR>', { buffer = bufnr, desc = 'Hover' })
          end,
        },
      }
    end,
  },
  {
    'mfussenegger/nvim-jdtls',
    lazy = true,
  },
}
