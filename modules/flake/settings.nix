{
  debug = true;

  flake-file = {
    inputs.systems.url = "github:nix-systems/default-linux";

    nixConfig = {
      allow-import-from-derivation = false;
      extra-experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };
}
