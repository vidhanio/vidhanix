{
  flake.aspects.nixvim.homeManager = _: {
    programs.nixvim = {
      plugins.lspconfig.enable = true;
      plugins.schemastore.enable = true;

      lsp.servers = {
        # keep-sorted start
        jsonls.enable = true;
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

      # registered while a language server is attached.
      lsp.keymaps = [
        {
          key = "K";
          lspBufAction = "hover";
          options = {
            silent = true;
            desc = "Hover documentation";
          };
        }
        {
          key = "<leader>rn";
          lspBufAction = "rename";
          options = {
            silent = true;
            desc = "Rename symbol";
          };
        }
        {
          key = "<leader>ca";
          lspBufAction = "code_action";
          mode = [
            "n"
            "v"
          ];
          options = {
            silent = true;
            desc = "Code action";
          };
        }
      ];

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
          mode = "n";
          key = "<leader>d";
          action.__raw = "vim.diagnostic.open_float";
          options = {
            silent = true;
            desc = "Show diagnostics";
          };
        }
        {
          mode = "n";
          key = "[d";
          action.__raw = "function() vim.diagnostic.jump({ count = -1, float = true }) end";
          options = {
            silent = true;
            desc = "Previous diagnostic";
          };
        }
        {
          mode = "n";
          key = "]d";
          action.__raw = "function() vim.diagnostic.jump({ count = 1, float = true }) end";
          options = {
            silent = true;
            desc = "Next diagnostic";
          };
        }
      ];
    };
  };
}
