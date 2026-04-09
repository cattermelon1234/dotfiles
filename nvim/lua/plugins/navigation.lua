local map = vim.keymap.set

return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local builtin = require("telescope.builtin")
      map("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      map("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      map("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
      map("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
      map("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Document Symbols" })
      map("n", "<leader>fS", builtin.lsp_workspace_symbols, { desc = "Workspace Symbols" })
      map("n", "<leader>fd", builtin.lsp_definitions, { desc = "Find definitions across workspace" })
      map("n", "<leader>fr", builtin.lsp_references, { desc = "Find references across workspace" })
    end,
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    cond = vim.fn.executable("make") == 1,
    config = function()
      vim.defer_fn(function()
        pcall(function()
          require("telescope").load_extension("fzf")
        end)
      end, 50)
    end,
  },
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("diffview").setup({})
    end,
  },
}
