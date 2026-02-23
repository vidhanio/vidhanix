{
  flake.modules.nixvim.default = {
    plugins.snacks.settings.picker = {
      enabled = true;
    };

    keymaps = [
      {
        key = "<leader><space>";
        action.__raw = "function() Snacks.picker.smart() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Smart Find Files";
        };
      }
      {
        key = "<leader>,";
        action.__raw = "function() Snacks.picker.buffers() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Buffers";
        };
      }
      {
        key = "<leader>/";
        action.__raw = "function() Snacks.picker.grep() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Grep";
        };
      }
      {
        key = "<leader>:";
        action.__raw = "function() Snacks.picker.command_history() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Command History";
        };
      }
      {
        key = "<leader>n";
        action.__raw = "function() Snacks.picker.notifications() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Notification History";
        };
      }
      {
        key = "<leader>fb";
        action.__raw = "function() Snacks.picker.buffers() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Buffers";
        };
      }
      {
        key = "<leader>ff";
        action.__raw = "function() Snacks.picker.files() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Find Files";
        };
      }
      {
        key = "<leader>fg";
        action.__raw = "function() Snacks.picker.git_files() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Find Git Files";
        };
      }
      {
        key = "<leader>fp";
        action.__raw = "function() Snacks.picker.projects() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Projects";
        };
      }
      {
        key = "<leader>fr";
        action.__raw = "function() Snacks.picker.recent() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Recent";
        };
      }
      {
        key = "<leader>gb";
        action.__raw = "function() Snacks.picker.git_branches() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Git Branches";
        };
      }
      {
        key = "<leader>gl";
        action.__raw = "function() Snacks.picker.git_log() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Git Log";
        };
      }
      {
        key = "<leader>gL";
        action.__raw = "function() Snacks.picker.git_log_line() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Git Log Line";
        };
      }
      {
        key = "<leader>gs";
        action.__raw = "function() Snacks.picker.git_status() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Git Status";
        };
      }
      {
        key = "<leader>gS";
        action.__raw = "function() Snacks.picker.git_stash() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Git Stash";
        };
      }
      {
        key = "<leader>gd";
        action.__raw = "function() Snacks.picker.git_diff() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Git Diff (Hunks)";
        };
      }
      {
        key = "<leader>gf";
        action.__raw = "function() Snacks.picker.git_log_file() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Git Log File";
        };
      }
      {
        key = "<leader>gi";
        action.__raw = "function() Snacks.picker.gh_issue() end";
        mode = "n";
        options = {
          silent = true;
          desc = "GitHub Issues (open)";
        };
      }
      {
        key = "<leader>gI";
        action.__raw = "function() Snacks.picker.gh_issue({ state = 'all' }) end";
        mode = "n";
        options = {
          silent = true;
          desc = "GitHub Issues (all)";
        };
      }
      {
        key = "<leader>gp";
        action.__raw = "function() Snacks.picker.gh_pr() end";
        mode = "n";
        options = {
          silent = true;
          desc = "GitHub Pull Requests (open)";
        };
      }
      {
        key = "<leader>gP";
        action.__raw = "function() Snacks.picker.gh_pr({ state = 'all' }) end";
        mode = "n";
        options = {
          silent = true;
          desc = "GitHub Pull Requests (all)";
        };
      }
      {
        key = "<leader>sb";
        action.__raw = "function() Snacks.picker.lines() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Buffer Lines";
        };
      }
      {
        key = "<leader>sB";
        action.__raw = "function() Snacks.picker.grep_buffers() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Grep Open Buffers";
        };
      }
      {
        key = "<leader>sg";
        action.__raw = "function() Snacks.picker.grep() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Grep";
        };
      }
      {
        key = "<leader>sw";
        action.__raw = "function() Snacks.picker.grep_word() end";
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
        action.__raw = "function() Snacks.picker.registers() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Registers";
        };
      }
      {
        key = "<leader>s/";
        action.__raw = "function() Snacks.picker.search_history() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Search History";
        };
      }
      {
        key = "<leader>sa";
        action.__raw = "function() Snacks.picker.autocmds() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Autocmds";
        };
      }
      {
        key = "<leader>sc";
        action.__raw = "function() Snacks.picker.command_history() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Command History";
        };
      }
      {
        key = "<leader>sC";
        action.__raw = "function() Snacks.picker.commands() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Commands";
        };
      }
      {
        key = "<leader>sd";
        action.__raw = "function() Snacks.picker.diagnostics() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Diagnostics";
        };
      }
      {
        key = "<leader>sD";
        action.__raw = "function() Snacks.picker.diagnostics_buffer() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Buffer Diagnostics";
        };
      }
      {
        key = "<leader>sh";
        action.__raw = "function() Snacks.picker.help() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Help Pages";
        };
      }
      {
        key = "<leader>sH";
        action.__raw = "function() Snacks.picker.highlights() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Highlights";
        };
      }
      {
        key = "<leader>si";
        action.__raw = "function() Snacks.picker.icons() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Icons";
        };
      }
      {
        key = "<leader>sj";
        action.__raw = "function() Snacks.picker.jumps() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Jumps";
        };
      }
      {
        key = "<leader>sk";
        action.__raw = "function() Snacks.picker.keymaps() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Keymaps";
        };
      }
      {
        key = "<leader>sl";
        action.__raw = "function() Snacks.picker.loclist() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Location List";
        };
      }
      {
        key = "<leader>sm";
        action.__raw = "function() Snacks.picker.marks() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Marks";
        };
      }
      {
        key = "<leader>sM";
        action.__raw = "function() Snacks.picker.man() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Man Pages";
        };
      }
      {
        key = "<leader>sq";
        action.__raw = "function() Snacks.picker.qflist() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Quickfix List";
        };
      }
      {
        key = "<leader>sR";
        action.__raw = "function() Snacks.picker.resume() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Resume";
        };
      }
      {
        key = "<leader>su";
        action.__raw = "function() Snacks.picker.undo() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Undo History";
        };
      }
      {
        key = "gd";
        action.__raw = "function() Snacks.picker.lsp_definitions() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Goto Definition";
        };
      }
      {
        key = "gD";
        action.__raw = "function() Snacks.picker.lsp_declarations() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Goto Declaration";
        };
      }
      {
        key = "gr";
        action.__raw = "function() Snacks.picker.lsp_references() end";
        mode = "n";
        options = {
          silent = true;
          nowait = true;
          desc = "References";
        };
      }
      {
        key = "gI";
        action.__raw = "function() Snacks.picker.lsp_implementations() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Goto Implementation";
        };
      }
      {
        key = "gy";
        action.__raw = "function() Snacks.picker.lsp_type_definitions() end";
        mode = "n";
        options = {
          silent = true;
          desc = "Goto T[y]pe Definition";
        };
      }
      {
        key = "gai";
        action.__raw = "function() Snacks.picker.lsp_incoming_calls() end";
        mode = "n";
        options = {
          silent = true;
          desc = "C[a]lls Incoming";
        };
      }
      {
        key = "gao";
        action.__raw = "function() Snacks.picker.lsp_outgoing_calls() end";
        mode = "n";
        options = {
          silent = true;
          desc = "C[a]lls Outgoing";
        };
      }
      {
        key = "<leader>ss";
        action.__raw = "function() Snacks.picker.lsp_symbols() end";
        mode = "n";
        options = {
          silent = true;
          desc = "LSP Symbols";
        };
      }
      {
        key = "<leader>sS";
        action.__raw = "function() Snacks.picker.lsp_workspace_symbols() end";
        mode = "n";
        options = {
          silent = true;
          desc = "LSP Workspace Symbols";
        };
      }
    ];
  };
}
