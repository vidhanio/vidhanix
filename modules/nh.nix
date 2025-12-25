{
  flake.modules.nixos.default = nixos: {
    programs.nh = {
      enable = true;
      flake = "${nixos.config.users.users.vidhanio.home}/Projects/vidhanix";
    };
  };
}
