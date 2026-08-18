{
  flake.aspects.nixvim = {
    nixvim = {
      plugins.mini.modules.clue = {
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
          { __raw = "require('mini.clue').gen_clues.g()"; }
          { __raw = "require('mini.clue').gen_clues.z()"; }
          { __raw = "require('mini.clue').gen_clues.marks()"; }
          { __raw = "require('mini.clue').gen_clues.registers()"; }
          { __raw = "require('mini.clue').gen_clues.windows()"; }
        ];
      };
    };
  };
}
