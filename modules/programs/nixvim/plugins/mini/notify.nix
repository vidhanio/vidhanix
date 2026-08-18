{
  flake.aspects.nixvim = {
    nixvim = {
      plugins.mini.modules.notify = { };

      keymaps = [
        {
          key = "<leader>n";
          action.__raw = "function() require('mini.notify').show_history() end";
          mode = "n";
          options = {
            silent = true;
            desc = "Notification History";
          };
        }
      ];
    };
  };
}
