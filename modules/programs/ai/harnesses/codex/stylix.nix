{ inputs, ... }:
{
  flake.modules.homeManager.default =
    { config, ... }:
    {
      programs.codex.settings.tui.theme = "base16-stylix";

      home.file.".codex/themes/base16-stylix.tmTheme".source = config.lib.stylix.colors {
        template = builtins.readFile "${inputs.stylix}/modules/bat/base16-stylix.tmTheme.mustache";
        extension = ".tmTheme";
      };
    };
}
