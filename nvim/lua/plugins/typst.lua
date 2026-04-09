return {
  {
    "kaarmu/typst.vim",
    ft = "typst",
  },
  {
    "sylvanfranklin/omni-preview.nvim",
    opts = {},
    dependencies = {
      { "chomosuke/typst-preview.nvim", lazy = true },
    },
    cmd = { "OmniPreview" },
    keys = {
      { "<leader>pt", "<cmd>OmniPreview start<CR>", desc = "OmniPreview Start" },
      { "<leader>pT", "<cmd>OmniPreview stop<CR>", desc = "OmniPreview Stop" },
    },
  },
}
