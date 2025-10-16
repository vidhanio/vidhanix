{ _class, lib, ... }:
lib.mkIf (_class == "darwin") {
  # use determinate nix
  nix.enable = false;
}
