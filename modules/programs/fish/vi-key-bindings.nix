{
  flake.modules.nixos.default = {
    programs.fish.shellInit = ''
      fish_vi_key_bindings
    '';
  };
}
