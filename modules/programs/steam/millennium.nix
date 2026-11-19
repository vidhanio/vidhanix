{
  profiles.pc.homeModule =
    { pkgs, ... }:
    {
      programs.millennium = {
        enable = true;
        themes.space-theme-steam = pkgs.fetchFromGitHub {
          owner = "SpaceTheme";
          repo = "Steam";
          rev = "65bc106e8a1fe04c359d5b9d5c6f00e4081506ef";
          hash = "sha256-TjPGjKQLicT6nKp1iqKtNmHpeKhXZIekAmfZCLhFHic=";
        };
        settings.themes = {
          activeTheme = "space-theme-steam";
          conditions.space-theme-steam."System accent colors" = "no";
        };
      };

      persist.directories = [ ".config/millennium" ];
    };
}
