{
  flake.modules.nixos.default = {
    security.sudo.extraConfig = ''
      Defaults lecture = never
    '';
  };
}
