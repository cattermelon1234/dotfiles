return {
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
          "tinymist",
        },
        automatic_installation = true,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
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

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "typst",
        callback = function()
          vim.opt_local.wrap = true
          vim.opt_local.linebreak = true
          vim.opt_local.spell = true
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "typst",
        callback = function()
          vim.keymap.set("n", "<leader>tpd", function()
            local file = vim.api.nvim_buf_get_name(0)
            if file == "" then
              vim.notify("No file name", vim.log.levels.ERROR)
              return
            end

            vim.cmd("write")
            local output = file:gsub("%.typ$", ".pdf")
            local cmd = string.format("typst compile %s %s", file, output)
            vim.notify("Compiling Typst → PDF...")
            vim.fn.jobstart(cmd, {
              on_exit = function(_, code)
                if code == 0 then
                  vim.notify("PDF generated: " .. output)
                else
                  vim.notify("Typst compile failed", vim.log.levels.ERROR)
                end
              end,
            })
          end, { desc = "Typst Compile to PDF" })
        end,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client then
            vim.notify("LSP attached: " .. client.name, vim.log.levels.INFO)
          end

          local mapbuf = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = args.buf, desc = "LSP: " .. desc })
          end

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

      vim.lsp.config("pyright", {
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
        root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", "pyrightconfig.json", ".git" },
        capabilities = capabilities,
      })

      vim.lsp.config("ts_ls", {
        cmd = { "typescript-language-server", "--stdio" },
        filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
        root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
        capabilities = capabilities,
      })

      vim.lsp.config("jdtls", {
        cmd = { "jdtls" },
        filetypes = { "java" },
        root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" },
        capabilities = capabilities,
      })

      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
        },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
        root_markers = { ".clangd", ".clang-tidy", ".clang-format", "compile_commands.json", "compile_flags.txt", "configure.ac", ".git" },
        capabilities = capabilities,
      })

      vim.lsp.config("html", {
        cmd = { "vscode-html-language-server", "--stdio" },
        filetypes = { "html" },
        root_markers = { "package.json", ".git" },
        capabilities = capabilities,
      })

      vim.lsp.config("cssls", {
        cmd = { "vscode-css-language-server", "--stdio" },
        filetypes = { "css", "scss", "less" },
        root_markers = { "package.json", ".git" },
        capabilities = capabilities,
      })

      vim.lsp.config("jsonls", {
        cmd = { "vscode-json-language-server", "--stdio" },
        filetypes = { "json", "jsonc" },
        root_markers = { "package.json", ".git" },
        capabilities = capabilities,
      })

      vim.lsp.config("tinymist", {
        cmd = { "tinymist" },
        filetypes = { "typst" },
        root_markers = { ".git", "typst.toml" },
        capabilities = capabilities,
      })

      vim.lsp.enable({ "lua_ls", "pyright", "ts_ls", "jdtls", "clangd", "html", "cssls", "jsonls", "tinymist" })
    end,
  },
}
