return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.o.background = "dark"
      require("catppuccin").setup({
        flavour = "frappe",
        styles = { comments = { "italic" }, keywords = { "italic" }, conditionals = { "italic" } },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
