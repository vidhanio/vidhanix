{
  perSystem.files.gitignore = "Session.vim";

  flake.aspects.nixvim.homeManager = {
    programs.nixvim = {
      plugins.mini.modules.sessions.autoread = true;

      keymaps = [
        {
          mode = "n";
          key = "<leader>Ss";
          action.__raw = "function() require('mini.sessions').write(require('mini.sessions').config.file) end";
          options = {
            silent = true;
            desc = "Save session";
          };
        }
        {
          mode = "n";
          key = "<leader>Sl";
          action.__raw = "function() require('mini.sessions').select('read') end";
          options = {
            silent = true;
            desc = "Load session";
          };
        }
        {
          mode = "n";
          key = "<leader>Sd";
          action.__raw = "function() require('mini.sessions').select('delete') end";
          options = {
            silent = true;
            desc = "Delete session";
          };
        }
      ];
    };
  };
}
