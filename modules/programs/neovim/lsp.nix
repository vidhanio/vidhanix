{
  flake.modules.nixvim.default = {
    lsp = {
      enable = true;
      servers = {
        # keep-sorted start block=yes
        nil_ls.enable = true;
        ruff.enable = true;
        rust-analyzer.enable = true;
        tailwindcss.enable = true;
        tinymist.enable = true;
        tombi.enable = true;
        ty.enable = true;
        yamlls.enable = true;
        # keep-sorted end
      };
    };

    plugins = {
      fidget.enable = true;
      lspconfig.enable = true;
      trouble.enable = true;
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
      {
        key = "<leader>xx";
        action = "<cmd>Trouble diagnostics toggle<CR>";
        mode = "n";
        options = {
          silent = true;
          desc = "Workspace diagnostics";
        };
      }
      {
        key = "<leader>xd";
        action = "<cmd>Trouble diagnostics toggle filter.buf=0<CR>";
        mode = "n";
        options = {
          silent = true;
          desc = "Document diagnostics";
        };
      }
      {
        key = "<leader>xq";
        action = "<cmd>Trouble qflist toggle<CR>";
        mode = "n";
        options = {
          silent = true;
          desc = "Quickfix list";
        };
      }
      {
        key = "<leader>xl";
        action = "<cmd>Trouble loclist toggle<CR>";
        mode = "n";
        options = {
          silent = true;
          desc = "Location list";
        };
      }
    ];
  };
}
