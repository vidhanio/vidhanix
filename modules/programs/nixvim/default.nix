{ inputs, ... }:
{
  flake-file.inputs.nixvim = {
    url = "github:nix-community/nixvim";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.aspects.nixvim = {
    homeManager =
      { pkgs, ... }:
      {
        imports = [ inputs.nixvim.homeModules.nixvim ];

        programs.nixvim = {
          enable = true;
          defaultEditor = true;
          viAlias = true;

          nixpkgs.useGlobalPackages = true;

          clipboard = {
            register = "unnamedplus";
            providers.wl-copy.enable = true;
          };

          globals.mapleader = " ";

          plugins.mini = {
            enable = true;
            mockDevIcons = true;
          };

          opts = {
            conceallevel = 2;
            confirm = true;
            expandtab = true;
            foldlevelstart = 99;
            laststatus = 3;
            relativenumber = true;
            scrolloff = 8;
            shiftround = true;
            shiftwidth = 2;
            sidescrolloff = 8;
            smoothscroll = true;
            tabstop = 2;
            timeoutlen = 300;
            undolevels = 10000;
            updatetime = 200;
            winborder = "none";
            winminwidth = 5;
          };

          # wrap long lines in prose, breaking at word boundaries.
          autoCmd = [
            {
              event = [ "FileType" ];
              pattern = [ "markdown" ];
              command = "setlocal wrap linebreak";
            }
          ];

          keymaps = [
            {
              mode = "n";
              key = "<Esc>";
              action = "<cmd>nohlsearch<CR>";
              options = {
                silent = true;
                desc = "Clear search highlight";
              };
            }
            {
              mode = "n";
              key = "<leader>w";
              action = "<cmd>write<CR>";
              options = {
                silent = true;
                desc = "Save file";
              };
            }
            {
              mode = "n";
              key = "<leader>q";
              action = "<cmd>quit<CR>";
              options = {
                silent = true;
                desc = "Quit";
              };
            }
            {
              mode = "n";
              key = "<leader>bd";
              action.__raw = "function() require('mini.bufremove').delete() end";
              options = {
                silent = true;
                desc = "Delete buffer";
              };
            }
            {
              mode = "n";
              key = "<A-j>";
              action = "<cmd>execute 'move .+' . v:count1<CR>==";
              options = {
                silent = true;
                desc = "Move down";
              };
            }
            {
              mode = "n";
              key = "<A-k>";
              action = "<cmd>execute 'move .-' . (v:count1 + 1)<CR>==";
              options = {
                silent = true;
                desc = "Move up";
              };
            }
            {
              mode = "i";
              key = "<A-j>";
              action = "<esc><cmd>m .+1<CR>==gi";
              options = {
                silent = true;
                desc = "Move down";
              };
            }
            {
              mode = "i";
              key = "<A-k>";
              action = "<esc><cmd>m .-2<CR>==gi";
              options = {
                silent = true;
                desc = "Move up";
              };
            }
            {
              mode = "v";
              key = "<A-j>";
              action = ":<C-u>execute \"'<,'>move '>+\" . v:count1<CR>gv=gv";
              options = {
                silent = true;
                desc = "Move down";
              };
            }
            {
              mode = "v";
              key = "<A-k>";
              action = ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<CR>gv=gv";
              options = {
                silent = true;
                desc = "Move up";
              };
            }
          ];

          extraPackages = with pkgs; [
            # keep-sorted start
            shfmt
            stylua
            treefmt
            wakatime-cli
            # keep-sorted end
          ];
        };

        persist.directories = [
          ".local/share/nvim"
          ".local/state/nvim"
        ];
      };
  };
}
