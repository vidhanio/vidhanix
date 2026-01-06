{ lib, inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  flake-file.inputs.treefmt-nix.url = "github:numtide/treefmt-nix";

  perSystem =
    { pkgs, config, ... }:
    {
      treefmt = {
        programs = {
          nixfmt.enable = true;
          statix.enable = true;
          deadnix.enable = true;

          shfmt.enable = true;
          shellcheck.enable = true;

          actionlint.enable = true;
          yamlfmt.enable = true;

          prettier.enable = true;

          xmllint.enable = true;
        };

        settings = {
          on-unmatched = "fatal";

          # https://github.com/numtide/treefmt-nix/pull/459
          formatter.xmllint.command = lib.mkForce (
            pkgs.writeShellApplication {
              name = "xmllint-wrapper";
              text = ''
                temp=$(mktemp)
                trap 'rm "$temp"' EXIT
                for file in "$@"; do
                  ${lib.getExe' config.treefmt.programs.xmllint.package "xmllint"} --format "$file" --output "$temp"
                  if ! cmp -s "$file" "$temp"; then
                    cp "$temp" "$file"
                  fi
                done
              '';
            }
          );
        };
      };

      pre-commit.settings.hooks.treefmt = {
        enable = true;
        pass_filenames = false;
      };
    };
}
