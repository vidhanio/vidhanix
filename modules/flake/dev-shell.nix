{ inputs, den, ... }:
{
  imports = [
    inputs.devshell.flakeModule
  ];

  flake-file.inputs.devshell.url = "github:numtide/devshell";

  den.classes.devshell = { };

  den.policies.devshell-to-flake-parts = _: [
    (den.lib.policy.route {
      fromClass = "devshell";
      intoClass = "flake-parts";
      path = [
        "devshells"
        "default"
      ];
      adaptArgs = { config, ... }: config.allModuleArgs;
    })
  ];

  den.schema.flake-parts.includes = [
    den.policies.devshell-to-flake-parts
    {
      files.commentedFile.".envrc".text = ''
        # shellcheck shell=bash
        use flake
      '';

      devshell =
        { config, pkgs, ... }:
        {
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
    }
  ];
}
