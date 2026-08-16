{ flake-parts-lib, lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { config, pkgs, ... }:
    {
      options.files.workflows = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = { };
        description = "GitHub Actions workflows to generate, one file per attr.";
      };

      config = {
        treefmt.programs.actionlint.enable = true;
        # generated workflow files carry `${{ }}` expressions whose quoting
        # oxfmt normalizes differently than the generator; keep them verbatim.
        treefmt.programs.oxfmt.excludes = [ ".github/workflows/*" ];

        # render with nixpkgs' yaml writer (remarshal) instead of a
        # hand-rolled emitter; commentedFile prepends the generated comment
        # and formats the result with treefmt.
        files.commentedFile = lib.mapAttrs' (
          name: workflow:
          lib.nameValuePair ".github/workflows/${name}.yaml" {
            fileType = "yaml";
            source = pkgs.writers.writeYAML "${name}.yaml" workflow;
          }
        ) config.files.workflows;
      };
    }
  );
}
