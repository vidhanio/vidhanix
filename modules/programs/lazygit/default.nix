{ lib, ... }:
{
  flake.aspects.lazygit = {
    homeManager =
      { pkgs, ... }:
      {
        programs.lazygit = {
          enable = true;
          settings = {
            gui.border = "single";

            git.diffRenderers = [
              {
                type = "extDiff";
                command = "${lib.getExe pkgs.difftastic} --color=always --context={{diffContext}}";
              }
            ];
          };
        };

        persist.directories = [ ".local/state/lazygit" ];
      };
  };
}
