{
  flake.modules.homeManager.default = {
    persist.directories = [
      "Downloads"
      "Projects"

      ".cache/nix"
    ];
  };
}
