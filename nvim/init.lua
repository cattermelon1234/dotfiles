-- --------- Basic Settings ----------
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.cindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.cursorline = false
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.clipboard = "unnamedplus"
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.updatetime = 250
vim.opt.startofline = false

vim.cmd([[
  filetype plugin indent on
]])

vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  pattern = { "*" },
  callback = function()
    if vim.bo.modified and vim.fn.getcmdwintype() == "" then
      vim.cmd("silent! write")
    end
  end,
})

vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false, border = "rounded" })
  end,
})

vim.diagnostic.config({
  virtual_text = false, -- no inline text
  signs = true,         -- keep VSCode-style gutter icons
  underline = true,     -- underline errors in buffer
  update_in_insert = true,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "if_many",
    focusable = false,
  },
})

-- Set up diagnostic underline colors (red squigglies like VS Code)
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = "#db4b4b" })
    vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = "#e0af68" })
    vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { undercurl = true, sp = "#0db9d7" })
    vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { undercurl = true, sp = "#1abc9c" })
  end,
})

-- Apply immediately
vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = "#db4b4b" })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = "#e0af68" })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { undercurl = true, sp = "#0db9d7" })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { undercurl = true, sp = "#1abc9c" })

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- --------- Keymaps ----------
local map = vim.keymap.set

-- MOVED: Register override keymaps will be set AFTER plugins load (see bottom of file)

--- terminal opening and deletion shortcuts
map("n", "<leader>t", ":split | term<CR>")  -- horizontal
map("n", "<leader>T", ":vsplit | term<CR>") -- vertical
map("n", "<leader>h", ":nohlsearch<CR>")
map("n", "<leader>w", ":w<CR>")
map("n", "<leader>q", ":q<CR>")
map("i", "jk", "<Esc>", { desc = "Escape insert mode" })

-- Window navigation with Alt
map("n", "<A-h>", "<C-w>h")
map("n", "<A-j>", "<C-w>j")
map("n", "<A-k>", "<C-w>k")
map("n", "<A-l>", "<C-w>l")

--- line movements with Ctrl
map("n", "<C-j>", ":m .+1<CR>==")
map("n", "<C-k>", ":m .-2<CR>==")
map("v", "<C-j>", ":m '>+1<CR>==gv")
map("v", "<C-k>", ":m '<-2<CR>==gv")

-- Jump back after gd (Ctrl-o goes back, Ctrl-i goes forward in jump list)
map("n", "gb", "<C-o>", { desc = "Go back in jump list" })
map("n", "gf", "<C-i>", { desc = "Go forward in jump list" })

-- Jump to matching bracket/brace
map("n", "%", "%", { desc = "Jump to matching bracket" })
-- Alternative: use <leader>% for easier access
map("n", "<leader>%", "%", { desc = "Jump to matching bracket" })

-- Terminal escape
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function(args)
    vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = args.buf })
  end,
})

-- --------- Plugin Manager: lazy.nvim ----------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- --------- Plugin Setup ----------
vim.g.lazy_lockfile = vim.fn.stdpath("state") .. "/lazy-lock.json"
require("lazy").setup({


  -- === Catppuccin Theme ===
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte | frappe | macchiato | mocha
        transparent_background = false,
        term_colors = true,
        styles = {
          comments = { "italic" },
          keywords = { "italic" },
          functions = {},
          variables = {},
        },
        integrations = {
          treesitter = true,
          native_lsp = {
            enabled = true,
          },
        },
      })
      vim.cmd("colorscheme catppuccin")
    end,
  },
  -- === Status Line ===
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "tokyonight",
          component_separators = { left = "│", right = "│" },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { "filename" },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- === File Tree ===
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 30 },
        renderer = {
          group_empty = true,
          icons = {
            glyphs = {
              folder = {
                arrow_closed = "",
                arrow_open = "",
              },
            },
          },
        },
        filters = { dotfiles = false },
        update_focused_file = {
          enable = true,
          update_cwd = true,
        },
        filesystem_watchers = {
          enable = true,
          debounce_delay = 50,
        },
      })
      map("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file tree" })
    end,
  },

  -- === Telescope ===
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
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

      -- Global definition search using Telescope
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

  -- === Treesitter ===
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      -- Use pcall but don't show warnings - just silently skip if not available
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

  -- === nvim-surround ===
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
  },

  -- === GitHub Copilot ===
  {
    "github/copilot.vim",
    lazy = false,
  },

  -- === Mason (LSP Installer) ===
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })
    end,
  },

  -- === Mason LSP Config ===
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "pyright",
          "ts_ls",
          "html",
          "cssls",
          "jsonls",
          "jdtls",
          "clangd",
        },
        automatic_installation = true,
      })
    end,
  },
  {
    "nvzone/typr",
    dependencies = "nvzone/volt",
    opts = {},
    cmd = { "Typr", "TyprStats" },
  },
  {
    "declancm/cinnamon.nvim",
    config = function()
      require("cinnamon").setup({
        keymaps = {
          basic = true,
          extra = true,
        },
        options = {
          delay = 5,
          max_delta = { time = 250 },
        },
      })
    end
  },

  -- === LSP Configuration (Modern vim.lsp.config API) ===
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- Diagnostic signs
      local signs = {
        Error = "󰅚 ",
        Warn = "󰀪 ",
        Hint = "󰌶 ",
        Info = " ",
      }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- LSP keymaps when attached
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client then
            vim.notify("LSP attached: " .. client.name, vim.log.levels.INFO)
          end

          local mapbuf = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = args.buf, desc = "LSP: " .. desc })
          end

          -- Keybindings
          mapbuf("gd", vim.lsp.buf.definition, "Goto Definition")
          mapbuf("gD", vim.lsp.buf.declaration, "Goto Declaration")
          mapbuf("gr", vim.lsp.buf.references, "Goto References")
          mapbuf("gi", vim.lsp.buf.implementation, "Goto Implementation")
          mapbuf("K", vim.lsp.buf.hover, "Hover Documentation")
          mapbuf("<leader>k", vim.diagnostic.open_float, "Show Diagnostics")
          mapbuf("<leader>ca", vim.lsp.buf.code_action, "Code Action")
          mapbuf("<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
          mapbuf("<leader>f", function()
            vim.lsp.buf.format({ async = false })
          end, "Format Document")
          mapbuf("[d", vim.diagnostic.goto_prev, "Previous Diagnostic")
          mapbuf("]d", vim.diagnostic.goto_next, "Next Diagnostic")
        end,
      })

      -- Use modern vim.lsp.config API
      -- Lua Language Server
      vim.lsp.config("lua_ls", {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
              },
            },
            telemetry = {
              enable = false,
            },
          },
        },
        capabilities = capabilities,
      })

      -- Python
      vim.lsp.config("pyright", {
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
        root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", "pyrightconfig.json", ".git" },
        capabilities = capabilities,
      })

      -- TypeScript/JavaScript
      vim.lsp.config("ts_ls", {
        cmd = { "typescript-language-server", "--stdio" },
        filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
        root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
        capabilities = capabilities,
      })

      -- Java
      vim.lsp.config("jdtls", {
        cmd = { "jdtls" },
        filetypes = { "java" },
        root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" },
        capabilities = capabilities,
      })

      -- C/C++
      vim.lsp.config("clangd", {
        cmd = {
          "clangd"
        },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
        root_markers = { ".clangd", ".clang-tidy", ".clang-format", "compile_commands.json", "compile_flags.txt", "configure.ac", ".git" },
        capabilities = capabilities,
      })

      -- HTML
      vim.lsp.config("html", {
        cmd = { "vscode-html-language-server", "--stdio" },
        filetypes = { "html" },
        root_markers = { "package.json", ".git" },
        capabilities = capabilities,
      })

      -- CSS
      vim.lsp.config("cssls", {
        cmd = { "vscode-css-language-server", "--stdio" },
        filetypes = { "css", "scss", "less" },
        root_markers = { "package.json", ".git" },
        capabilities = capabilities,
      })

      -- JSON
      vim.lsp.config("jsonls", {
        cmd = { "vscode-json-language-server", "--stdio" },
        filetypes = { "json", "jsonc" },
        root_markers = { "package.json", ".git" },
        capabilities = capabilities,
      })

      -- Enable LSP servers
      vim.lsp.enable({ "lua_ls", "pyright", "ts_ls", "jdtls", "clangd", "html", "cssls", "jsonls" })
    end,
  },

  -- === Autocompletion ===
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0
            and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            -- Try Copilot first
            local copilot_status = vim.fn["copilot#Accept"]("")
            if copilot_status ~= "" then
              vim.api.nvim_feedkeys(copilot_status, "i", true)
            elseif cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        formatting = {
          format = function(entry, vim_item)
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snip]",
              buffer = "[Buf]",
              path = "[Path]",
            })[entry.source.name]
            return vim_item
          end,
        },
      })
    end,
  },

  -- === Auto Pairs ===
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({
        enable_check_bracket_line = false,
        ignored_next_char = "[%w%.]",
      })
    end,
  },

  -- === Commenting ===
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  {
    "Pocco81/auto-save.nvim",
    config = function()
      require("auto-save").setup({
        enabled = true,
        triggers = { "InsertLeave", "TextChanged" }, -- when to save
        debounce_delay = 500,                        -- ms
      })
    end
  },
  {
    "ojroques/nvim-osc52",
    config = function()
      require("osc52").setup({
        max_length = 0, -- unlimited
        silent = true,
        trim = false,
        tmux_passthrough = true,
      })

      -- Auto-copy yanked text to OSC52 (for containers/SSH)
      local function copy_to_osc52(lines, regtype)
        -- Only copy if there's actual content
        if #lines > 0 then
          local text = table.concat(lines, "\n")
          require("osc52").copy(text)
        end
      end

      -- Hook into yank events
      vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
          if vim.v.event.operator == 'y' and vim.v.event.regname == '' then
            copy_to_osc52(vim.v.event.regcontents, vim.v.event.regtype)
          end
        end,
      })
    end,
  },
})

-- ===== Auto-format on save =====
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.java", "*.cpp", "*.c", "*.lua", "*.py", "*.js", "*.ts" },
  callback = function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    for _, client in ipairs(clients) do
      if client.supports_method("textDocument/formatting") then
        vim.lsp.buf.format({
          async = false,
          id = client.id,
        })
        break
      end
    end
  end,
})

vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = "#FF0000" })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = "#FFA500" })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { undercurl = true, sp = "#00AFFF" })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { undercurl = true, sp = "#00FFAA" })

-- Register override keymaps (after plugins load)
vim.defer_fn(function()
  vim.keymap.set("n", "d", "\"dd", { noremap = true, desc = "Delete to d register" })
  vim.keymap.set("n", "D", "\"dD", { noremap = true, desc = "Delete line to d register" })
  vim.keymap.set("n", "c", "\"dc", { noremap = true, desc = "Change to d register" })
  vim.keymap.set("n", "C", "\"dC", { noremap = true, desc = "Change line to d register" })
  vim.keymap.set("n", "x", "\"dx", { noremap = true, desc = "Delete char to d register" })

  vim.keymap.set("v", "d", "\"dd", { noremap = true, desc = "Delete to d register" })
  vim.keymap.set("v", "c", "\"dc", { noremap = true, desc = "Change to d register" })
  vim.keymap.set("v", "x", "\"dx", { noremap = true, desc = "Delete to d register" })

  vim.keymap.set("n", "<leader>d", "\"dP", { noremap = true, desc = "Paste from d register" })
  vim.keymap.set("v", "<leader>d", "\"dp", { noremap = true, desc = "Paste from d register" })
end, 100)
