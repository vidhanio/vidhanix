{
  flake.aspects.nixvim.nixvim = {
    plugins.statuscol = {
      enable = true;
      settings.segments = [
        {
          text = [
            { __raw = "require('statuscol.builtin').lnumfunc"; }
            " "
          ];
          condition = [
            true
            { __raw = "require('statuscol.builtin').not_empty"; }
          ];
          click = "v:lua.ScLa";
        }
        {
          text = [
            { __raw = "require('statuscol.builtin').signfunc"; }
            " "
          ];
          sign = {
            namespace = [ "MiniDiff" ];
            colwidth = 1;
            fillchar = "│";
            fillcharhl = "LineNr";
          };
          click = "v:lua.ScSa";
        }
      ];
    };
  };
}
