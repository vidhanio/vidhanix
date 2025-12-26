{
  flake.modules.homeManager.default = {
    persist.directories = map (d: ".config/retroarch/${d}") [
      "saves"
      "states"
    ];
  };
}
