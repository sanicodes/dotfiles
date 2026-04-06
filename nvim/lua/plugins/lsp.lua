return {
  {
    'mason-org/mason.nvim',
    version = '>=2.0',
    config = true,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'mason-org/mason.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
    config = function()
      vim.diagnostic.config {
        virtual_text = { prefix = '●', spacing = 2 },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      }

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', require('telescope.builtin').lsp_definitions, 'Goto Definition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, 'Document Symbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Workspace Symbols')

          local client = vim.lsp.get_client_by_id(event.data.client_id)

          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_group = vim.api.nvim_create_augroup('lsp-highlight-' .. event.buf, { clear = true })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_group,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_group,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('lsp-detach-' .. event.buf, { clear = true }),
              callback = function()
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = highlight_group, buffer = event.buf }
              end,
            })
          end

          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, 'Toggle Inlay Hints')
          end
        end,
      })

      local servers = {
        emmet_ls = {},
        pyright = {},
        eslint = {
          on_attach = function(client)
            client.server_capabilities.documentFormattingProvider = true
            client.server_capabilities.documentRangeFormattingProvider = true
          end,
        },
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { 'vim' } },
              completion = { callSnippet = 'Replace' },
            },
          },
        },
      }

      local ensure_installed = vim.tbl_keys(servers)
      local linters = require('lint').linters_by_ft
      vim.list_extend(ensure_installed, { 'stylua' })
      for _, linters_list in pairs(linters) do
        vim.list_extend(ensure_installed, linters_list)
      end

      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      for server_name, server_config in pairs(servers) do
        vim.lsp.config(server_name, server_config)
      end

      require('mason-lspconfig').setup {
        automatic_enable = vim.tbl_keys(servers),
      }
    end,
  },
}
