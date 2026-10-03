{
  flake.aspects.nixvim.homeManager = {
    programs.nixvim = {
      extraConfigLuaPre = ''
        require('vim._core.ui2').enable({ enable = true })
      '';

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
              keys = "<leader>f";
              desc = "Find";
            }
          ];
        };
        statusline = { };
        tabline = { };
      };

      # nixvim has no mini.input module.
      extraConfigLua = "require('mini.input').setup()";
    };
  };
}
