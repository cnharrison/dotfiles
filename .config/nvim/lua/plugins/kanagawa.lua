return {
  {
    "rebelot/kanagawa.nvim",
    name = "kanagawa",
    event = "VimEnter",
    config = function()
      require("kanagawa").setup({
        transparent = true,
        theme = "wave",
        colors = {
          theme = {
            all = {
              ui = {
                bg_gutter = "none",
              },
            },
          },
        },
        integrations = {
          cmp = true,
          telescope = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          notify = true,
        },
      })
      vim.cmd.colorscheme("kanagawa")
    end,
  },
}
