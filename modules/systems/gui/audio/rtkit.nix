{
  flake.aspects.audio.nixos = {
    security.rtkit.enable = true;
  };
}
