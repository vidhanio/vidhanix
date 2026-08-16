{ flake-parts-lib, lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { config, pkgs, ... }:
    {
      options.workflows = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = { };
        description = "GitHub Actions workflows to generate, one file per attr.";
      };

      config = {
        # render with nixpkgs' yaml writer (remarshal) instead of a
        # hand-rolled emitter; commentedFile prepends the generated comment
        # and formats the result with treefmt.
        files.commentedFile = lib.mapAttrs' (
          name: workflow:
          lib.nameValuePair ".github/workflows/${name}.yaml" {
            fileType = "yaml";
            source = pkgs.writers.writeYAML "${name}.yaml" workflow;
          }
        ) config.workflows;
      };
    }
  );
}
