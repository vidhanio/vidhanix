{ inputs, ... }:
{
  imports = [
    inputs.make-shell.flakeModules.default
  ];

  flake-file.inputs.make-shell.url = "github:nicknovitski/make-shell";

  perSystem =
    {
      config,
      pkgs,
      ...
    }:
    {
      files.commentedFile.".envrc".text = ''
        # shellcheck shell=bash
        use flake
      '';

      make-shells.default =
        let
          rebuild = pkgs.writeShellApplication {
            name = "rebuild";

            derivationArgs = {
              preferLocalBuild = true;
              allowSubstitutes = false;
            };

            runtimeInputs = with pkgs; [
              git
              nix
              nh
            ];

            text = ''
              git add -AN

              nix run .#generate-files

              nh os "''${@:-switch}"
            '';
          };
        in
        {
          inherit (config.pre-commit) shellHook;

          packages = config.pre-commit.settings.enabledPackages ++ [
            pkgs.git
            pkgs.direnv

            pkgs.nil

            pkgs.sops
            pkgs.ssh-to-age

            rebuild
          ];
        };
    };
}
