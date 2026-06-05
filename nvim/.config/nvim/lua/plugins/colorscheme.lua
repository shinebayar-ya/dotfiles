return {
  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    priority = 1000, -- load before other start plugins
    config = function()
      require("github-theme").setup({})
      vim.cmd([[colorscheme github_light_colorblind]])
    end,
  },
}
