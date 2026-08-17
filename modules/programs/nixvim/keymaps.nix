{
  flake.aspects.nixvim.nixvim = {
    keymaps = [
      {
        key = "<Esc>";
        action = "<cmd>nohlsearch<CR>";
        mode = "n";
        options = {
          silent = true;
          desc = "Clear search highlight";
        };
      }
      {
        key = "<leader>w";
        action = "<cmd>write<CR>";
        mode = "n";
        options = {
          silent = true;
          desc = "Save file";
        };
      }
      {
        key = "<leader>q";
        action = "<cmd>quit<CR>";
        mode = "n";
        options = {
          silent = true;
          desc = "Quit";
        };
      }
      {
        key = "<S-l>";
        action = "<cmd>bnext<CR>";
        mode = "n";
        options = {
          silent = true;
          desc = "Next buffer";
        };
      }
      {
        key = "<S-h>";
        action = "<cmd>bprevious<CR>";
        mode = "n";
        options = {
          silent = true;
          desc = "Previous buffer";
        };
      }
      {
        key = "<leader>bd";
        action.__raw = "function() require('mini.bufremove').delete() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Delete buffer";
        };
      }
    ];
  };
}
