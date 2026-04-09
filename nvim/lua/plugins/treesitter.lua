return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      pcall(function()
        require("nvim-treesitter.configs").setup({
          ensure_installed = {
            "lua",
            "python",
            "javascript",
            "typescript",
            "html",
            "css",
            "json",
            "markdown",
            "java",
            "cpp",
            "c",
            "bash",
            "typst",
          },
          highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
          },
          indent = {
            enable = true,
            disable = { "java" },
          },
          auto_install = true,
        })
      end)
    end,
  },
}
