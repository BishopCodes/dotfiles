return {
  "saghen/blink.cmp",
  enabled = false,
  lazy = false, -- lazy loading handled internally
  -- optional: provides snippets for the snippet source
  dependencies = {
    "rafamadriz/friendly-snippets",
    "saghen/blink.compat",
  },

  -- use a release tag to download pre-built binaries
  version = "v0.*",
  -- OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
  -- build = 'cargo build --release',
  -- If you use nix, you can build from source using latest nightly rust with:
  -- build = 'nix run .#build-plugin',

  ---@module 'blink.cmp'
  ---@diagnostic disable-next-line: undefined-doc-name
  ---@type blink.cmp.Config
  opts = {
    keymap = "default",
    -- windows = {
    --   documentation = {
    --     auto_show = true,
    --   },
    -- },
    highlight = {
      -- sets the fallback highlight groups to nvim-cmp's highlight groups
      -- useful for when your theme doesn't support blink.cmp
      -- will be removed in a future release, assuming themes add support
      use_nvim_cmp_as_default = true,
    },
    -- set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
    -- adjusts spacing to ensure icons are aligned
    nerd_font_variant = "normal",

    -- experimental auto-brackets support
    -- accept = { auto_brackets = { enabled = true } }

    -- experimental signature help support
    -- trigger = { signature_help = { enabled = true } }
  },
  sources = {
    completion = {
      -- remember to enable your providers here
      enabled_providers = { "lsp", "path", "snippets", "buffer", "lazydev" },
    },

    providers = {
      lazydev = {
        name = "lazydev", -- IMPORTANT: use the same name as you would for nvim-cmp
        module = "blink.compat",

        -- all blink.cmp source config options work as normal:
        score_offset = 3,

        opts = {
          -- options for the completion source
          -- equivalent to `option` field of nvim-cmp source config
        },
      },
    },
  },
}
