{
  flake.aspects.nixvim.homeManager = {
    programs.nixvim = {
      plugins.mini.modules = {
        extra = { };
        files = {
          windows.preview = true;
        };
        pick = { };
      };

      extraFiles."lua/pickers.lua".source = ./lua/pickers.lua;

      extraConfigLua = "require('pickers').setup()";

      # netrw owns the FileExplorer event that mini.files clears; load it first.
      extraConfigLuaPre = "vim.cmd('runtime! plugin/netrwPlugin.vim')";

      keymaps = [
        {
          mode = "n";
          key = "<leader><space>";
          action.__raw = "function() require('pickers').smart() end";
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
          action.__raw = "function() require('pickers').buffers() end";
          options = {
            silent = true;
            desc = "Buffers";
          };
        }
        {
          mode = "n";
          key = "<leader>fd";
          action.__raw = "function() require('pickers').diagnostics() end";
          options = {
            silent = true;
            desc = "Diagnostics";
          };
        }
        {
          mode = "n";
          key = "<leader>ff";
          action.__raw = "function() require('pickers').files() end";
          options = {
            silent = true;
            desc = "Find files";
          };
        }
        {
          mode = "n";
          key = "<leader>fg";
          action.__raw = "function() require('pickers').grep() end";
          options = {
            silent = true;
            desc = "Grep";
          };
        }
        {
          mode = "n";
          key = "<leader>fs";
          action.__raw = "function() require('pickers').symbols() end";
          options = {
            silent = true;
            desc = "Symbols";
          };
        }
      ];
    };
  };
}
