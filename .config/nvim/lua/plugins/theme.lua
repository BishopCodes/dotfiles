return {
  -- {
  --   "baliestri/aura-theme",
  --   lazy = false,
  --   priority = 1000,
  --   config = function(plugin)
  --     vim.opt.rtp:append(plugin.dir .. "/packages/neovim")
  --     vim.cmd([[colorscheme aura-dark]])
  --   end,
  -- },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    opts = {
      integrations = {
        aerial = true,
        alpha = true,
        cmp = true,
        dashboard = true,
        flash = true,
        grug_far = true,
        gitsigns = true,
        headlines = true,
        illuminate = true,
        indent_blankline = { enabled = true },
        leap = true,
        lsp_trouble = true,
        mason = true,
        markdown = true,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        navic = { enabled = true, custom_bg = "lualine" },
        neotest = true,
        neotree = true,
        noice = true,
        notify = true,
        semantic_tokens = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        which_key = true,
      },
    },
    config = function()
      require("catppuccin").setup({
        flavour = "macchiato",
        highlight_overrides = {
          all = function(colors)
            local overrides = {
              Headline = { style = { "bold" } },
            }
            for _, hl in ipairs({ "Headline", "rainbow" }) do
              for i, c in ipairs({ "blue", "mauve", "teal", "green", "peach", "flamingo" }) do
                overrides[hl .. i] = { fg = colors[c], style = { "bold" } }
              end
            end
            return overrides
          end,
          -- This is a comment and for the love of ...
          macchiato = function(colors)
            local overrides = {
              CurSearch = { bg = colors.peach },
              CursorLineNr = { fg = colors.blue, style = { "bold" } },
              FloatTitle = { fg = colors.mauve },
              Headline = { style = { "bold" } },
              IncSearch = { bg = colors.peach },
              MsgArea = { fg = colors.overlay1 },
              Search = { bg = colors.mauve, fg = colors.base },
              TreesitterContextBottom = { sp = colors.overlay1, style = { "underline" } },
              WinSeparator = { fg = colors.surface1, style = { "bold" } },

              -- Better markdown code block compat w/ mini.hues
              KazCodeBlock = { bg = colors.crust },

              -- Links to Comment by default, but that has italics
              LeapBackdrop = { link = "MiniJump2dDim" },
              LeapLabel = { fg = colors.peach, style = { "bold" } },
              -- LeapLabel = { fg = colors.base, bg = colors.peach, style = { "bold" } },

              -- Mini customizations
              MiniClueDescGroup = { fg = colors.pink },
              MiniClueDescSingle = { fg = colors.sapphire },
              MiniClueNextKey = { fg = colors.text, style = { "bold" } },

              MiniFilesCursorLine = { fg = nil, bg = colors.surface1, style = { "bold" } },
              MiniFilesFile = { fg = colors.overlay2 },
              MiniFilesTitleFocused = { fg = colors.peach, style = { "bold" } },

              -- Highlight patterns for highlighting the whole line and hiding colon.
              -- See https://github.com/echasnovski/mini.nvim/discussions/783
              MiniHipatternsFixmeBody = { fg = colors.red, bg = colors.base },
              MiniHipatternsFixmeColon = { bg = colors.red, fg = colors.red, style = { "bold" } },
              MiniHipatternsHackBody = { fg = colors.yellow, bg = colors.base },
              MiniHipatternsHackColon = {
                bg = colors.yellow,
                fg = colors.yellow,
                style = { "bold" },
              },
              MiniHipatternsNoteBody = { fg = colors.sky, bg = colors.base },
              MiniHipatternsNoteColon = { bg = colors.sky, fg = colors.sky, style = { "bold" } },
              MiniHipatternsTodoBody = { fg = colors.teal, bg = colors.base },
              MiniHipatternsTodoColon = { bg = colors.teal, fg = colors.teal, style = { "bold" } },

              MiniIndentscopeSymbol = { fg = colors.sapphire },

              MiniJump = { fg = colors.mantle, bg = colors.pink },
              MiniJump2dSpot = { fg = colors.peach },
              MiniJump2dSpotAhead = { fg = colors.mauve },
              MiniJump2dSpotUnique = { fg = colors.peach },

              MiniMapNormal = { fg = colors.overlay2, bg = colors.mantle },

              MiniPickBorderText = { fg = colors.blue },
              MiniPickMatchCurrent = { fg = nil, bg = colors.surface1, style = { "bold" } },
              MiniPickMatchRanges = { fg = colors.text, style = { "bold" } },
              MiniPickNormal = { fg = colors.overlay2 },
              MiniPickPrompt = { fg = colors.mauve },

              MiniStarterInactive = { fg = colors.overlay0, style = {} },
              MiniStarterItem = { fg = colors.overlay2, bg = nil },
              MiniStarterItemBullet = { fg = colors.surface2 },
              MiniStarterItemPrefix = { fg = colors.text },
              MiniStarterQuery = { fg = colors.text, style = { "bold" } },
              MiniStarterSection = { fg = colors.mauve, style = { "bold" } },

              MiniStatuslineDirectory = { fg = colors.overlay1, bg = colors.surface0 },
              MiniStatuslineFilename = {
                fg = colors.text,
                bg = colors.surface0,
                style = { "bold" },
              },
              MiniStatuslineFilenameModified = {
                fg = colors.blue,
                bg = colors.surface0,
                style = { "bold" },
              },
              MiniStatuslineInactive = { fg = colors.overlay1, bg = colors.surface0 },

              MiniSurround = { fg = nil, bg = colors.yellow },

              MiniTablineCurrent = { fg = colors.blue, bg = colors.base, style = { "bold" } },
              MiniTablineFill = { bg = colors.mantle },
              MiniTablineHidden = { fg = colors.overlay1, bg = colors.surface0 },
              MiniTablineModifiedCurrent = {
                fg = colors.base,
                bg = colors.blue,
                style = { "bold" },
              },
              MiniTablineModifiedHidden = { fg = colors.base, bg = colors.subtext0 },
              MiniTablineModifiedVisible = {
                fg = colors.base,
                bg = colors.subtext0,
                style = { "bold" },
              },
              MiniTablineTabpagesection = {
                fg = colors.base,
                bg = colors.mauve,
                style = { "bold" },
              },
              MiniTablineVisible = {
                fg = colors.overlay1,
                bg = colors.surface0,
                style = { "bold" },
              },
            }
            for _, hl in ipairs({ "Headline", "rainbow" }) do
              for i, c in ipairs({ "blue", "pink", "lavender", "green", "peach", "flamingo" }) do
                overrides[hl .. i] = { fg = colors[c], style = { "bold" } }
              end
            end
            return overrides
          end,
        },
        color_overrides = {
          macchiato = {
            rosewater = "#F5B8AB",
            flamingo = "#F29D9D",
            pink = "#AD6FF7",
            mauve = "#FF8F40",
            red = "#E66767",
            maroon = "#EB788B",
            peach = "#FAB770",
            yellow = "#FACA64",
            green = "#70CF67",
            teal = "#4CD4BD",
            sky = "#61BDFF",
            sapphire = "#4BA8FA",
            blue = "#00BFFF",
            lavender = "#00BBCC",
            text = "#C1C9E6",
            subtext1 = "#A3AAC2",
            subtext0 = "#8E94AB",
            overlay2 = "#7D8296",
            overlay1 = "#676B80",
            overlay0 = "#464957",
            surface2 = "#3A3D4A",
            surface1 = "#2F313D",
            surface0 = "#1D1E29",
            base = "#0b0b12",
            mantle = "#11111a",
            crust = "#191926",
          },
          --   macchiato = {
          --     rosewater = "#D9E0EE", -- Aura's foreground
          --     flamingo = "#F28FAD", -- Aura's red accent
          --     pink = "#F5C2E7", -- Aura's pink accent
          --     mauve = "#DDB6F2", -- Aura's mauve accent
          --     red = "#F28FAD", -- Aura's red accent
          --     maroon = "#E46876", -- Slightly darker red
          --     peach = "#F8BD96", -- Aura's peach/orange accent
          --     yellow = "#FAE3B0", -- Aura's yellow accent
          --     green = "#ABE9B3", -- Aura's green accent
          --     teal = "#89DCEB", -- Aura's teal accent
          --     sky = "#96CDFB", -- Aura's blue accent
          --     sapphire = "#7DC4E4", -- Slightly different shade of blue
          --     blue = "#96CDFB", -- Aura's main blue accent
          --     lavender = "#C9CBFF", -- Aura's lavender accent
          --     text = "#D9E0EE", -- Aura's foreground
          --     subtext1 = "#BAC2DE", -- Slightly darker than the text
          --     subtext0 = "#A6ADC8", -- Slightly darker than subtext1
          --     overlay2 = "#9399B2", -- Overlay shades
          --     overlay1 = "#7F849C",
          --     overlay0 = "#6C7086",
          --     surface2 = "#585B70",
          --     surface1 = "#45475A",
          --     surface0 = "#313244",
          --     base = "#1E1E2E", -- Aura's background
          --     mantle = "#181825", -- Slightly darker than the base
          --     crust = "#11111B", -- Even darker background
          --   },
        },
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-macchiato",
    },
  },
}
