return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
  },
  config = function()
    vim.diagnostic.config({
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.HINT] = "󰠠 ",
          [vim.diagnostic.severity.INFO] = " ",
        },
      },
    })

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
      callback = function(event)
        local map = function(mode, keys, func, desc)
          vim.keymap.set(mode, keys, func, { buffer = event.buf, silent = true, desc = desc })
        end

        map("n", "gR", vim.lsp.buf.references, "Show references")
        map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        map("n", "gd", vim.lsp.buf.definition, "Go to definition")
        map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
        map("n", "gt", vim.lsp.buf.type_definition, "Go to type definition")
        map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("n", "<leader>rn", vim.lsp.buf.rename, "Smart rename")
        map("n", "K", vim.lsp.buf.hover, "Hover documentation")
        map("n", "<leader>rs", "<cmd>LspRestart<CR>", "Restart LSP")
        map("n", "<leader>d", vim.diagnostic.open_float, "Show line diagnostics")
        map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, "Previous diagnostic")
        map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")
      end,
    })

    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    local servers = {
      clangd = {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=never", 
        },
      },
      html = {},
      ts_ls = {},
      cssls = {},
      tailwindcss = {},
      prismals = {},
      pyright = {},
      lua_ls = {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = {
                [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                [vim.fn.stdpath("config") .. "/lua"] = true,
              },
            },
          },
        },
      },
      graphql = {
        filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
      },
      emmet_ls = {
        filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
      },
      svelte = {},
      intelephense = {
        settings = {
          intelephense = {
            environment = {
              phpVersion = "7.2.0",
            },
          },
        },
      },
    }

    for server, config in pairs(servers) do
      config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})
      vim.lsp.config(server, config)
      vim.lsp.enable(server)
    end

    vim.api.nvim_create_autocmd("BufWritePost", {
      group = vim.api.nvim_create_augroup("SvelteTsJsNotify", { clear = true }),
      pattern = { "*.js", "*.ts" },
      callback = function(ctx)
        local clients = vim.lsp.get_clients({ name = "svelte" })
        for _, client in ipairs(clients) do
          client.notify("$/onDidChangeTsOrJsFile", { uri = vim.uri_from_fname(ctx.file) })
        end
      end,
    })
  end,
}
