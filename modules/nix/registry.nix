{ lib, inputs, ... }:
let
  flakes = lib.filterAttrs (_: input: input ? _type && input._type == "flake") inputs;
in
{
  flake.modules.nixos.default = {
    nix.registry = lib.mapAttrs (_: flake: { inherit flake; }) flakes;
  };
}
