let
  plugin =
    { lib, ... }:
    lib.nixvim.plugins.mkNeovimPlugin {
      name = "jupynvim";

      maintainers = [ ];

      description = "VSCode-style Jupyter notebook editing in Neovim";

      settingsOptions = {
        core_path = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Path to the `jupynvim-core` binary.";
        };

        auto_install = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to download a matching release binary at runtime when the core is missing or stale.";
        };
      };
    };
in
{
  flake.aspects.nixvim.homeManager = {
    programs.nixvim.imports = [ plugin ];
  };
}
