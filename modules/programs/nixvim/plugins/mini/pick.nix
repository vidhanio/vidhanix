{
  flake.aspects.nixvim = {
    nixvim = {
      plugins.mini.modules.pick = { };

      keymaps = [
        {
          key = "<leader><space>";
          action.__raw = "function() require('mini.pick').builtin.files() end";
          mode = "n";
          options = {
            silent = true;
            desc = "Find Files";
          };
        }
        {
          key = "<leader>,";
          action.__raw = "function() require('mini.pick').builtin.buffers() end";
          mode = "n";
          options = {
            silent = true;
            desc = "Buffers";
          };
        }
        {
          key = "<leader>/";
          action.__raw = "function() require('mini.pick').builtin.grep_live() end";
          mode = "n";
          options = {
            silent = true;
            desc = "Grep";
          };
        }
        {
          key = "<leader>:";
          action.__raw = "function() require('mini.extra').pickers.history({ scope = ':' }) end";
          mode = "n";
          options = {
            silent = true;
            desc = "Command History";
          };
        }
        {
          key = "<leader>fb";
          action.__raw = "function() require('mini.pick').builtin.buffers() end";
          mode = "n";
          options = {
            silent = true;
            desc = "Buffers";
          };
        }
        {
          key = "<leader>ff";
          action.__raw = "function() require('mini.pick').builtin.files() end";
          mode = "n";
          options = {
            silent = true;
            desc = "Find Files";
          };
        }
        {
          key = "<leader>fg";
          action.__raw = "function() require('mini.extra').pickers.git_files() end";
          mode = "n";
          options = {
            silent = true;
            desc = "Find Git Files";
          };
        }
        {
          key = "<leader>fr";
          action.__raw = "function() require('mini.extra').pickers.oldfiles() end";
          mode = "n";
          options = {
            silent = true;
            desc = "Recent";
          };
        }
        {
          key = "<leader>gb";
          action.__raw = "function() require('mini.extra').pickers.git_branches() end";
          mode = "n";
          options = {
            silent = true;
            desc = "Git Branches";
          };
        }
        {
          key = "<leader>gl";
          action.__raw = "function() require('mini.extra').pickers.git_commits() end";
          mode = "n";
          options = {
            silent = true;
            desc = "Git Log";
          };
        }
        {
          key = "<leader>gs";
          action.__raw = "function() require('mini.extra').pickers.git_files({ scope = 'modified' }) end";
          mode = "n";
          options = {
            silent = true;
            desc = "Git Status (Modified Files)";
          };
        }
        {
          key = "<leader>gd";
          action.__raw = "function() require('mini.extra').pickers.git_hunks({ scope = 'unstaged' }) end";
          mode = "n";
          options = {
            silent = true;
            desc = "Git Diff (Hunks)";
          };
        }
        {
          key = "<leader>gf";
          action.__raw = "function() require('mini.extra').pickers.git_commits({ path = '%' }) end";
          mode = "n";
          options = {
            silent = true;
            desc = "Git Log File";
          };
        }
        {
          key = "<leader>sb";
          action.__raw = "function() require('mini.extra').pickers.buf_lines({ scope = 'current' }) end";
          mode = "n";
          options = {
            silent = true;
            desc = "Buffer Lines";
          };
        }
        {
          key = "<leader>sB";
          action.__raw = "function() require('mini.extra').pickers.buf_lines({ scope = 'all' }) end";
          mode = "n";
          options = {
            silent = true;
            desc = "Grep Open Buffers";
          };
        }
        {
          key = "<leader>sg";
          action.__raw = "function() require('mini.pick').builtin.grep_live() end";
          mode = "n";
          options = {
            silent = true;
            desc = "Grep";
          };
        }
        {
          key = "<leader>sw";
          action.__raw = ''
            function()
              local mode = vim.fn.mode()
              local pattern
              if mode == "v" or mode == "V" then
                vim.cmd("normal! \"vy")
                pattern = vim.fn.getreg("v")
              else
                pattern = vim.fn.expand("<cword>")
              end
              require("mini.pick").builtin.grep({ pattern = pattern })
            end
          '';
          mode = [
            "n"
            "x"
          ];
          options = {
            silent = true;
            desc = "Visual selection or word";
          };
        }
        {
          key = "<leader>s\"";
          action.__raw = "function() require('mini.extra').pickers.registers() end";
          mode = "n";
          options = {
            silent = true;
            desc = "Registers";
          };
        }
        {
          key = "<leader>s/";
          action.__raw = "function() require('mini.extra').pickers.history({ scope = '/' }) end";
          mode = "n";
          options = {
            silent = true;
            desc = "Search History";
          };
        }
        {
          key = "<leader>sc";
          action.__raw = "function() require('mini.extra').pickers.history({ scope = ':' }) end";
          mode = "n";
          options = {
            silent = true;
            desc = "Command History";
          };
        }
        {
          key = "<leader>sC";
          action.__raw = "function() require('mini.extra').pickers.commands() end";
          mode = "n";
          options = {
            silent = true;
            desc = "Commands";
          };
        }
        {
          key = "<leader>sd";
          action.__raw = "function() require('mini.extra').pickers.diagnostic({ scope = 'all' }) end";
          mode = "n";
          options = {
            silent = true;
            desc = "Diagnostics";
          };
        }
        {
          key = "<leader>sD";
          action.__raw = "function() require('mini.extra').pickers.diagnostic({ scope = 'current' }) end";
          mode = "n";
          options = {
            silent = true;
            desc = "Buffer Diagnostics";
          };
        }
        {
          key = "<leader>sh";
          action.__raw = "function() require('mini.pick').builtin.help() end";
          mode = "n";
          options = {
            silent = true;
            desc = "Help Pages";
          };
        }
        {
          key = "<leader>sH";
          action.__raw = "function() require('mini.extra').pickers.hl_groups() end";
          mode = "n";
          options = {
            silent = true;
            desc = "Highlights";
          };
        }
        {
          key = "<leader>sj";
          action.__raw = "function() require('mini.extra').pickers.list({ scope = 'jump' }) end";
          mode = "n";
          options = {
            silent = true;
            desc = "Jumps";
          };
        }
        {
          key = "<leader>sk";
          action.__raw = "function() require('mini.extra').pickers.keymaps() end";
          mode = "n";
          options = {
            silent = true;
            desc = "Keymaps";
          };
        }
        {
          key = "<leader>sl";
          action.__raw = "function() require('mini.extra').pickers.list({ scope = 'location' }) end";
          mode = "n";
          options = {
            silent = true;
            desc = "Location List";
          };
        }
        {
          key = "<leader>sm";
          action.__raw = "function() require('mini.extra').pickers.marks() end";
          mode = "n";
          options = {
            silent = true;
            desc = "Marks";
          };
        }
        {
          key = "<leader>sM";
          action.__raw = "function() require('mini.extra').pickers.manpages() end";
          mode = "n";
          options = {
            silent = true;
            desc = "Man Pages";
          };
        }
        {
          key = "<leader>sq";
          action.__raw = "function() require('mini.extra').pickers.list({ scope = 'quickfix' }) end";
          mode = "n";
          options = {
            silent = true;
            desc = "Quickfix List";
          };
        }
        {
          key = "<leader>sR";
          action.__raw = "function() require('mini.pick').builtin.resume() end";
          mode = "n";
          options = {
            silent = true;
            desc = "Resume";
          };
        }
        {
          key = "gd";
          action.__raw = "function() require('mini.extra').pickers.lsp({ scope = 'definition' }) end";
          mode = "n";
          options = {
            silent = true;
            desc = "Goto Definition";
          };
        }
        {
          key = "gD";
          action.__raw = "function() require('mini.extra').pickers.lsp({ scope = 'declaration' }) end";
          mode = "n";
          options = {
            silent = true;
            desc = "Goto Declaration";
          };
        }
        {
          key = "gr";
          action.__raw = "function() require('mini.extra').pickers.lsp({ scope = 'references' }) end";
          mode = "n";
          options = {
            silent = true;
            nowait = true;
            desc = "References";
          };
        }
        {
          key = "gI";
          action.__raw = "function() require('mini.extra').pickers.lsp({ scope = 'implementation' }) end";
          mode = "n";
          options = {
            silent = true;
            desc = "Goto Implementation";
          };
        }
        {
          key = "gy";
          action.__raw = "function() require('mini.extra').pickers.lsp({ scope = 'type_definition' }) end";
          mode = "n";
          options = {
            silent = true;
            desc = "Goto T[y]pe Definition";
          };
        }
        {
          key = "<leader>ss";
          action.__raw = "function() require('mini.extra').pickers.lsp({ scope = 'document_symbol' }) end";
          mode = "n";
          options = {
            silent = true;
            desc = "LSP Symbols";
          };
        }
        {
          key = "<leader>sS";
          action.__raw = "function() require('mini.extra').pickers.lsp({ scope = 'workspace_symbol' }) end";
          mode = "n";
          options = {
            silent = true;
            desc = "LSP Workspace Symbols";
          };
        }
      ];
    };
  };
}
