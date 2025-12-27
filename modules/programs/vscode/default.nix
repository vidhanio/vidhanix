{ withSystem, ... }:
{
  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      programs.vscode = withSystem pkgs.stdenvNoCC.hostPlatform.system {
        package = pkgs.vscode-insiders;
      };

      persist.directories = [
        ".config/Code - Insiders/User/globalStorage"
      ];
    };
}
