{
  flake.modules.nixvim.default.keymaps = [
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
      key = "<C-h>";
      action = "<C-w>h";
      mode = "n";
      options = {
        silent = true;
        desc = "Move to left window";
      };
    }
    {
      key = "<C-j>";
      action = "<C-w>j";
      mode = "n";
      options = {
        silent = true;
        desc = "Move to lower window";
      };
    }
    {
      key = "<C-k>";
      action = "<C-w>k";
      mode = "n";
      options = {
        silent = true;
        desc = "Move to upper window";
      };
    }
    {
      key = "<C-l>";
      action = "<C-w>l";
      mode = "n";
      options = {
        silent = true;
        desc = "Move to right window";
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
      action.__raw = "function() Snacks.bufdelete() end";
      mode = "n";
      options = {
        silent = true;
        desc = "Delete buffer";
      };
    }
  ];
}
