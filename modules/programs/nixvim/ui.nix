{
  flake.aspects.nixvim.homeManager = {
    programs.nixvim = {
      plugins.mini.modules = {
        cmdline = { };
        clue = {
          triggers = [
            {
              mode = "n";
              keys = "<leader>";
            }
            {
              mode = "x";
              keys = "<leader>";
            }
            {
              mode = "n";
              keys = "g";
            }
            {
              mode = "x";
              keys = "g";
            }
            {
              mode = "n";
              keys = "z";
            }
            {
              mode = "x";
              keys = "z";
            }
            {
              mode = "n";
              keys = "[";
            }
            {
              mode = "n";
              keys = "]";
            }
            {
              mode = "n";
              keys = "'";
            }
            {
              mode = "n";
              keys = "`";
            }
            {
              mode = "n";
              keys = "\"";
            }
            {
              mode = "x";
              keys = "\"";
            }
            {
              mode = "n";
              keys = "<c-w>";
            }
          ];
          clues = [
            {
              __raw = "require('mini.clue').gen_clues.g()";
            }
            {
              __raw = "require('mini.clue').gen_clues.z()";
            }
            {
              __raw = "require('mini.clue').gen_clues.marks()";
            }
            {
              __raw = "require('mini.clue').gen_clues.registers()";
            }
            {
              __raw = "require('mini.clue').gen_clues.windows()";
            }
            {
              mode = "n";
              keys = "<leader>b";
              desc = "Buffers";
            }
            {
              mode = "n";
              keys = "<leader>c";
              desc = "Code";
            }
            {
              mode = "n";
              keys = "<leader>f";
              desc = "Find";
            }
            {
              mode = "n";
              keys = "<leader>r";
              desc = "Rename";
            }
            {
              mode = "n";
              keys = "<leader>S";
              desc = "Session";
            }
          ];
        };
        indentscope = { };
        notify = { };
        tabline = { };

        # mini.statusline default content, with LSP progress in place of fidget.nvim.
        statusline.content.active.__raw = ''
          function()
            local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
            local git = MiniStatusline.section_git({ trunc_width = 40 })
            local diff = MiniStatusline.section_diff({ trunc_width = 75 })
            local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
            local lsp = MiniStatusline.section_lsp({ trunc_width = 75 })
            local progress = vim.ui.progress_status()
            local filename = MiniStatusline.section_filename({ trunc_width = 140 })
            local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
            local location = MiniStatusline.section_location({ trunc_width = 75 })
            local search = MiniStatusline.section_searchcount({ trunc_width = 75 })

            return MiniStatusline.combine_groups({
              { hl = mode_hl, strings = { mode } },
              { hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics, lsp, progress } },
              "%<",
              { hl = "MiniStatuslineFilename", strings = { filename } },
              "%=",
              { hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
              { hl = mode_hl, strings = { search, location } },
            })
          end
        '';
      };

      # nixvim has no mini.input module.
      extraConfigLua = "require('mini.input').setup()";

      keymaps = [
        {
          mode = "n";
          key = "<leader>n";
          action.__raw = "function() require('mini.notify').show_history() end";
          options = {
            silent = true;
            desc = "Notification history";
          };
        }
      ];
    };
  };
}
