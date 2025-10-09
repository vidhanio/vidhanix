{ _class, lib, ... }:
lib.optionalAttrs (_class == "darwin") {
  nix.enable = false;
}
