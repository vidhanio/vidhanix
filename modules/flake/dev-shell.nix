{ inputs, ... }:
{
  imports = [
    inputs.devshell.flakeModule
  ];

  flake-file.inputs.devshell.url = "github:numtide/devshell";

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

      devshells.default = {
        devshell.startup.pre-commit-hooks.text = config.pre-commit.shellHook;
        devshell.motd = "";

        packages = config.pre-commit.settings.enabledPackages ++ [
          pkgs.git
          pkgs.direnv

          pkgs.nil

          pkgs.sops

          pkgs.nh
        ];

        commands = [
          {
            name = "n";
            help = "regenerate generated files and apply the system configuration";
            command = ''
              git add -AN

              nix run .#generate-files

              nh os "''${@:-switch}"
            '';
          }
        ];
      };
    };
}
