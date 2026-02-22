{
  inputs,
  config,
  ...
}:
{
  flake-file.inputs.nixvim.url = "github:nix-community/nixvim";

  flake.modules = {
    nixos.default = {
      imports = [ inputs.nixvim.nixosModules.default ];

      programs.nixvim.imports = [ config.flake.modules.nixvim.default ];
    };
    homeManager.default = {
      imports = [ inputs.nixvim.homeModules.default ];

      programs.nixvim.imports = [ config.flake.modules.nixvim.default ];
    };
    nixvim.default =
      { lib, ... }:
      let
        u = lib.nixvim.utils;
      in
      {
        enable = true;
        defaultEditor = true;
        viAlias = true;

        clipboard = {
          register = "unnamedplus";
          providers.wl-copy.enable = true;
        };

        globals.mapleader = " ";
        opts = {
          number = true;
          signcolumn = "yes";
          scrolloff = 8;
          wrap = false;
          expandtab = true;
          shiftwidth = 2;
          tabstop = 2;
          undofile = true;
          splitright = true;
          splitbelow = true;
          foldlevelstart = 99;
        };

        lsp = {
          enable = true;
          servers = {
            # keep-sorted start block=yes
            nil_ls.enable = true;
            ruff.enable = true;
            rust-analyzer = {
              enable = true;
            };
            tailwindcss.enable = true;
            tinymist.enable = true;
            tombi.enable = true;
            ty.enable = true;
            yamlls.enable = true;
            # keep-sorted end
          };
        };

        plugins = {
          # keep-sorted start block=yes
          blink-cmp.enable = true;
          comment.enable = true;
          conform-nvim = {
            enable = true;
            settings = {
              formatters_by_ft."*" = [ "treefmt" ];
              formatters.treefmt.require_cwd = false;
              format_on_save = {
                timeout_ms = 500;
                lsp_fallback = true;
              };
            };
          };
          direnv.enable = true;
          fidget.enable = true;
          lsp-format.enable = true;
          lspconfig.enable = true;
          mini = {
            enable = true;
            mockDevIcons = true;
            modules.icons = { };
          };
          neo-tree = {
            enable = true;
            settings.filesystem.filtered_items.visible = true;
          };
          noice = {
            enable = true;
            settings = {
              lsp.override = {
                "vim.lsp.util.convert_input_to_markdown_lines" = true;
                "vim.lsp.util.stylize_markdown" = true;
                "cmp.entry.get_documentation" = true;
              };
              presets = {
                bottom_search = true;
                command_palette = true;
                long_message_to_split = true;
                inc_rename = false;
                lsp_doc_border = false;
              };
            };
          };
          nvim-autopairs.enable = true;
          nvim-surround.enable = true;
          opencode = {
            enable = true;
            settings.auto_reload = true;
          };
          snacks = {
            enable = true;
            settings = {
              # keep-sorted start block=true
              bigfile.enabled = true;
              image.enabled = true;
              input.enabled = true;
              lazygit.enabled = true;
              notifier.enabled = true;
              picker = {
                enabled = true;
                actions.opencode_send.__raw = "function(...) return require('opencode').snacks_picker_send(...) end";
                win.input.keys."<a-a>" = u.listToUnkeyedAttrs [ "opencode_send" ] // {
                  mode = [
                    "n"
                    "i"
                  ];
                };
              };
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
          treesitter = {
            enable = true;
            highlight.enable = true;
            indent.enable = true;
            folding.enable = true;
            statuscolumn.enable = true;
          };
          trouble.enable = true;
          wakatime.enable = true;
          which-key.enable = true;
          # keep-sorted end
        };

        keymaps =
          let
            s = desc: {
              silent = true;
              inherit desc;
            };
          in
          [
            {
              key = "<Esc>";
              action = "<cmd>nohlsearch<CR>";
              mode = "n";
              options = s "Clear search highlight";
            }
            {
              key = "<leader>w";
              action = "<cmd>write<CR>";
              mode = "n";
              options = s "Save file";
            }
            {
              key = "<leader>q";
              action = "<cmd>quit<CR>";
              mode = "n";
              options = s "Quit";
            }
            {
              key = "<C-h>";
              action = "<C-w>h";
              mode = "n";
              options = s "Move to left window";
            }
            {
              key = "<C-j>";
              action = "<C-w>j";
              mode = "n";
              options = s "Move to lower window";
            }
            {
              key = "<C-k>";
              action = "<C-w>k";
              mode = "n";
              options = s "Move to upper window";
            }
            {
              key = "<C-l>";
              action = "<C-w>l";
              mode = "n";
              options = s "Move to right window";
            }
            {
              key = "<S-l>";
              action = "<cmd>bnext<CR>";
              mode = "n";
              options = s "Next buffer";
            }
            {
              key = "<S-h>";
              action = "<cmd>bprevious<CR>";
              mode = "n";
              options = s "Previous buffer";
            }
            {
              key = "<leader>bd";
              action.__raw = "function() Snacks.bufdelete() end";
              mode = "n";
              options = s "Delete buffer";
            }
            {
              key = "<leader>nt";
              action = "<cmd>Neotree toggle<CR>";
              mode = "n";
              options = s "Toggle file tree";
            }
            {
              key = "<leader>nf";
              action = "<cmd>Neotree reveal<CR>";
              mode = "n";
              options = s "Reveal file in tree";
            }
            {
              key = "<leader>lg";
              action.__raw = "function() Snacks.lazygit() end";
              mode = "n";
              options = s "Lazygit";
            }
            {
              key = "<leader>ff";
              action.__raw = "function() Snacks.picker.files() end";
              mode = "n";
              options = s "Find files";
            }
            {
              key = "<leader>fg";
              action.__raw = "function() Snacks.picker.grep() end";
              mode = "n";
              options = s "Live grep";
            }
            {
              key = "<leader>fb";
              action.__raw = "function() Snacks.picker.buffers() end";
              mode = "n";
              options = s "Find buffers";
            }
            {
              key = "<leader>fh";
              action.__raw = "function() Snacks.picker.help() end";
              mode = "n";
              options = s "Help tags";
            }
            {
              key = "<leader>fr";
              action.__raw = "function() Snacks.picker.recent() end";
              mode = "n";
              options = s "Recent files";
            }
            {
              key = "<leader>fs";
              action.__raw = "function() Snacks.picker.lsp_symbols() end";
              mode = "n";
              options = s "Document symbols";
            }
            {
              key = "<leader>fw";
              action.__raw = "function() Snacks.picker.lsp_workspace_symbols() end";
              mode = "n";
              options = s "Workspace symbols";
            }
            {
              key = "gd";
              action.__raw = "function() vim.lsp.buf.definition() end";
              mode = "n";
              options = s "Go to definition";
            }
            {
              key = "gD";
              action.__raw = "function() vim.lsp.buf.declaration() end";
              mode = "n";
              options = s "Go to declaration";
            }
            {
              key = "gr";
              action.__raw = "function() Snacks.picker.lsp_references() end";
              mode = "n";
              options = s "Go to references";
            }
            {
              key = "gi";
              action.__raw = "function() vim.lsp.buf.implementation() end";
              mode = "n";
              options = s "Go to implementation";
            }
            {
              key = "K";
              action.__raw = "function() vim.lsp.buf.hover() end";
              mode = "n";
              options = s "Hover documentation";
            }
            {
              key = "<leader>rn";
              action.__raw = "function() vim.lsp.buf.rename() end";
              mode = "n";
              options = s "Rename symbol";
            }
            {
              key = "<leader>ca";
              action.__raw = "function() vim.lsp.buf.code_action() end";
              mode = [
                "n"
                "v"
              ];
              options = s "Code action";
            }
            {
              key = "<leader>d";
              action.__raw = "function() vim.diagnostic.open_float() end";
              mode = "n";
              options = s "Show diagnostics";
            }
            {
              key = "[d";
              action.__raw = "function() vim.diagnostic.goto_prev() end";
              mode = "n";
              options = s "Previous diagnostic";
            }
            {
              key = "]d";
              action.__raw = "function() vim.diagnostic.goto_next() end";
              mode = "n";
              options = s "Next diagnostic";
            }
            {
              key = "<leader>xx";
              action = "<cmd>Trouble diagnostics toggle<CR>";
              mode = "n";
              options = s "Workspace diagnostics";
            }
            {
              key = "<leader>xd";
              action = "<cmd>Trouble diagnostics toggle filter.buf=0<CR>";
              mode = "n";
              options = s "Document diagnostics";
            }
            {
              key = "<leader>xq";
              action = "<cmd>Trouble qflist toggle<CR>";
              mode = "n";
              options = s "Quickfix list";
            }
            {
              key = "<leader>xl";
              action = "<cmd>Trouble loclist toggle<CR>";
              mode = "n";
              options = s "Location list";
            }
            {
              key = "<C-.>";
              action.__raw = "function() require('opencode').toggle() end";
              mode = [
                "n"
                "t"
              ];
              options = s "Toggle OpenCode";
            }
            {
              key = "<C-a>";
              action.__raw = "function() require('opencode').ask('@this: ', { submit = true }) end";
              mode = [
                "n"
                "x"
              ];
              options = s "Ask OpenCode";
            }
            {
              key = "<C-x>";
              action.__raw = "function() require('opencode').select() end";
              mode = [
                "n"
                "x"
              ];
              options = s "OpenCode select";
            }
            {
              key = "go";
              action.__raw = "function() return require('opencode').operator('@this ') end";
              mode = "n";
              options = {
                expr = true;
                silent = true;
                desc = "Add range to OpenCode";
              };
            }
            {
              key = "goo";
              action.__raw = "function() return require('opencode').operator('@this ') .. '_' end";
              mode = "n";
              options = {
                expr = true;
                silent = true;
                desc = "Add line to OpenCode";
              };
            }
            {
              key = "<S-C-u>";
              action.__raw = "function() require('opencode').command('session.half.page.up') end";
              mode = "n";
              options = s "OpenCode scroll up";
            }
            {
              key = "<S-C-d>";
              action.__raw = "function() require('opencode').command('session.half.page.down') end";
              mode = "n";
              options = s "OpenCode scroll down";
            }
            {
              key = "<C-`>";
              action.__raw = "function() Snacks.terminal.toggle() end";
              mode = [
                "n"
                "t"
              ];
              options = s "Toggle terminal";
            }
          ];
      };
  };
}
