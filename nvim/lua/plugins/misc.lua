return {
  {
    "vyfor/cord.nvim",
    event = "VeryLazy",
    config = function()
      require("cord").setup({
        enabled = true,
        log_level = vim.log.levels.OFF,
        editor = {
          client = "neovim",
          tooltip = "being performative",
          icon = "neovim",
        },
        assets = {
          large_image = "neovim",
          large_text = "Neovim",
        },
        display = {
          view = "full",
          swap_icons = true,
          swap_fields = false,
        },
        text = {
          workspace = "",
          viewing = function(opts)
            return "Viewing " .. opts.filename
          end,
          editing = function(opts)
            return "Editing " .. opts.filename
          end,
          games = function(opts)
            return "Playing " .. opts.name
          end,
          terminal = function()
            return "playing ghostty +boo"
          end,
        },
      })
    end,
  },
  {
    "ojroques/nvim-osc52",
    config = function()
      require("osc52").setup({
        max_length = 0,
        silent = true,
        trim = false,
        tmux_passthrough = true,
      })

      local function copy_to_osc52(lines)
        if #lines > 0 then
          local text = table.concat(lines, "\n")
          require("osc52").copy(text)
        end
      end

      vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
          if vim.v.event.operator == "y" and vim.v.event.regname == "" then
            copy_to_osc52(vim.v.event.regcontents, vim.v.event.regtype)
          end
        end,
      })
    end,
  },
}
