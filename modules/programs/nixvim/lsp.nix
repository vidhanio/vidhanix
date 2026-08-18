{
  flake.aspects.nixvim = {
    nixvim = {
      lsp.servers = {
        # keep-sorted start
        nil_ls.enable = true;
        ruff.enable = true;
        rust-analyzer.enable = true;
        statix.enable = true;
        tailwindcss.enable = true;
        tinymist.enable = true;
        tombi.enable = true;
        ty.enable = true;
        yamlls.enable = true;
        # keep-sorted end
      };

      plugins.lspconfig.enable = true;

      diagnostic.settings = {
        virtual_text.prefix = "";
        signs.numhl.__raw = ''
          {
            [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
            [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
            [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
            [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
          }
        '';
      };

      keymaps = [
        {
          key = "K";
          action.__raw = "function() vim.lsp.buf.hover() end";
          mode = "n";
          options = {
            silent = true;
            desc = "Hover documentation";
          };
        }
        {
          key = "<leader>rn";
          action.__raw = "function() vim.lsp.buf.rename() end";
          mode = "n";
          options = {
            silent = true;
            desc = "Rename symbol";
          };
        }
        {
          key = "<leader>ca";
          action.__raw = "function() vim.lsp.buf.code_action() end";
          mode = [
            "n"
            "v"
          ];
          options = {
            silent = true;
            desc = "Code action";
          };
        }
        {
          key = "<leader>d";
          action.__raw = "function() vim.diagnostic.open_float() end";
          mode = "n";
          options = {
            silent = true;
            desc = "Show diagnostics";
          };
        }
        {
          key = "[d";
          action.__raw = "function() vim.diagnostic.goto_prev() end";
          mode = "n";
          options = {
            silent = true;
            desc = "Previous diagnostic";
          };
        }
        {
          key = "]d";
          action.__raw = "function() vim.diagnostic.goto_next() end";
          mode = "n";
          options = {
            silent = true;
            desc = "Next diagnostic";
          };
        }
      ];
    };
  };
}
