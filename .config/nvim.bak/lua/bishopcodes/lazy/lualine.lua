return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			options = {
				theme = "palenight",
				sections = {
					lualine_x = {
						"rest",
					},
				},
			},
		})
	end,
}
