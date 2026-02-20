{
  flake-parts-lib,
  lib,
  ...
}:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { config, ... }:
    let
      cfg = config.files.gitignore;
    in
    {
      options.files.gitignore = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "The content of the .gitignore file.";
      };

      config = {
        files.file.".gitignore".text = cfg;
      };
    }
  );
}
