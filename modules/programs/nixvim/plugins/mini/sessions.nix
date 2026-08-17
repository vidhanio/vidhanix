{
  perSystem.files.gitignore = "Session.vim";

  flake.aspects.nixvim.nixvim = {
    plugins.mini.modules.sessions.autoread = true;

    keymaps = [
      {
        key = "<leader>Ss";
        action.__raw = "function() require('mini.sessions').write(require('mini.sessions').config.file) end";
        mode = "n";
        options = {
          silent = true;
          desc = "Save Session";
        };
      }
      {
        key = "<leader>Sl";
        action.__raw = "function() require('mini.sessions').select('read') end";
        mode = "n";
        options = {
          silent = true;
          desc = "Load Session";
        };
      }
      {
        key = "<leader>Sd";
        action.__raw = "function() require('mini.sessions').select('delete') end";
        mode = "n";
        options = {
          silent = true;
          desc = "Delete Session";
        };
      }
    ];
  };
}
