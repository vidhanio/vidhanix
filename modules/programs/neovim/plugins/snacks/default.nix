{
  flake.modules.nixvim.default = {
    plugins.snacks = {
      enable = true;
      settings = {
        # keep-sorted start block=true
        animate.enabled = true;
        bigfile.enabled = true;
        bufdelete.enabled = true;
        explorer.enabled = true;
        gh.enabled = true;
        git.enabled = true;
        image.enabled = true;
        input.enabled = true;
        lazygit.enabled = true;
        notifier.enabled = true;
        quickfile.enabled = true;
        rename.enabled = true;
        scroll.enabled = true;
        statuscolumn.enabled = true;
        terminal = {
          enabled = true;
          win.style = "float";
        };
        words.enabled = true;
        # keep-sorted end
      };
    };

    keymaps = [
      {
        key = "<leader>e";
        action.__raw = "function() Snacks.explorer() end";
        mode = "n";
        options = {
          silent = true;
          desc = "File Explorer";
        };
      }
      {
        key = "<leader>gl";
        action.__raw = "function() Snacks.lazygit() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Lazygit";
        };
      }
      {
        key = "<C-`>";
        action.__raw = "function() Snacks.terminal.toggle() end";
        mode = [
          "n"
          "t"
        ];
        options = {
          silent = true;
          desc = "Toggle terminal";
        };
      }
    ];
  };
}
