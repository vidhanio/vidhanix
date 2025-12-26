{
  flake.modules.nixos.default = args: {
    programs.nh = {
      enable = true;
      flake = "${args.config.users.users.vidhanio.home}/Projects/vidhanix";
    };
  };
}
