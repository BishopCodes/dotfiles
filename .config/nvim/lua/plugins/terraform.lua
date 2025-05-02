return {
  -- Dummy Trigger
  "LazyVim/LazyVim",
  keys = {
    {
      "<leader>tv",
      function()
        require("util.terraform_var_gen").create_missing_variables()
      end,
      desc = "Terraform: Create Missing Variables",
    },
  },
}
