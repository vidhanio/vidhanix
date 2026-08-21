{
  flake.aspects.t3code = {
    homeManager =
      { config, ... }:
      {
        programs.t3code.clientSettings = {
          fontFamilyCode = config.stylix.fonts.monospace.name;
          fontFamilyTerminal = config.stylix.fonts.monospace.name;
          fontFamilyComposer = config.stylix.fonts.sansSerif.name;
          fontFamilySans = config.stylix.fonts.sansSerif.name;
        };
      };
  };
}
