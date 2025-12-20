{
  flake.modules.homeManager.default = {
    persist.directories = [
      ".local/share/keyrings"
    ];
  };
}
