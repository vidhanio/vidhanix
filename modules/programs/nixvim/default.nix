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
            completeopt = "menuone,noselect,popup";
            conceallevel = 2;
            confirm = true;
            cursorline = true;
            expandtab = true;
            foldlevelstart = 99;
            ignorecase = true;
            inccommand = "nosplit";
            laststatus = 3;
            linebreak = true;
            mouse = "a";
            number = true;
            pumheight = 10;
            relativenumber = true;
            scrolloff = 8;
            shiftround = true;
            shiftwidth = 2;
            showmode = false;
            sidescrolloff = 8;
            signcolumn = "yes";
            smartcase = true;
            smartindent = true;
            smoothscroll = true;
            splitbelow = true;
            splitright = true;
            tabstop = 2;
            termguicolors = true;
            timeoutlen = 300;
            undofile = true;
            undolevels = 10000;
            updatetime = 200;
            virtualedit = "block";
            winborder = "single";
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
              key = "<C-h>";
              action = "<C-w>h";
              options = {
                silent = true;
                desc = "Go to left window";
              };
            }
            {
              mode = "n";
              key = "<C-j>";
              action = "<C-w>j";
              options = {
                silent = true;
                desc = "Go to lower window";
              };
            }
            {
              mode = "n";
              key = "<C-k>";
              action = "<C-w>k";
              options = {
                silent = true;
                desc = "Go to upper window";
              };
            }
            {
              mode = "n";
              key = "<C-l>";
              action = "<C-w>l";
              options = {
                silent = true;
                desc = "Go to right window";
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
            {
              mode = [
                "n"
                "x"
              ];
              key = "j";
              action = "v:count == 0 ? 'gj' : 'j'";
              options = {
                expr = true;
                silent = true;
                desc = "Down";
              };
            }
            {
              mode = [
                "n"
                "x"
              ];
              key = "k";
              action = "v:count == 0 ? 'gk' : 'k'";
              options = {
                expr = true;
                silent = true;
                desc = "Up";
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
