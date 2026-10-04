{
  flake.aspects.nixvim.homeManager = {
    programs.nixvim = {
      plugins.mini.modules = {
        extra = { };
        files = { };
        pick = { };
      };

      extraFiles."lua/smartpick.lua".source = ./lua/smartpick.lua;

      # netrw owns the FileExplorer event that mini.files clears; load it first.
      extraConfigLuaPre = "vim.cmd('runtime! plugin/netrwPlugin.vim')";

      keymaps = [
        {
          mode = "n";
          key = "<leader><space>";
          action.__raw = "function() require('smartpick').picker() end";
          options = {
            silent = true;
            desc = "Smart find files";
          };
        }
        {
          mode = "n";
          key = "<leader>e";
          action.__raw = ''
            function()
              local path = vim.api.nvim_buf_get_name(0)
              require("mini.files").open(path ~= "" and path or nil)
            end
          '';
          options = {
            silent = true;
            desc = "Explorer";
          };
        }
        {
          mode = "n";
          key = "<leader>fb";
          action.__raw = "function() require('mini.pick').builtin.buffers() end";
          options = {
            silent = true;
            desc = "Buffers";
          };
        }
        {
          mode = "n";
          key = "<leader>fd";
          action.__raw = "function() require('mini.extra').pickers.diagnostic({ scope = 'all' }) end";
          options = {
            silent = true;
            desc = "Diagnostics";
          };
        }
        {
          mode = "n";
          key = "<leader>ff";
          action.__raw = "function() require('mini.pick').builtin.files() end";
          options = {
            silent = true;
            desc = "Find files";
          };
        }
        {
          mode = "n";
          key = "<leader>fg";
          action.__raw = "function() require('mini.pick').builtin.grep_live() end";
          options = {
            silent = true;
            desc = "Grep";
          };
        }
        {
          mode = "n";
          key = "<leader>fr";
          action.__raw = "function() require('mini.extra').pickers.oldfiles() end";
          options = {
            silent = true;
            desc = "Recent files";
          };
        }
        {
          mode = "n";
          key = "<leader>fs";
          action.__raw = "function() require('mini.extra').pickers.lsp({ scope = 'document_symbol' }) end";
          options = {
            silent = true;
            desc = "Symbols";
          };
        }
      ];
    };
  };
}
