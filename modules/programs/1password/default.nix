{
  flake.aspects._1password = {
    nixos = {
      programs._1password.enable = true;
    };
  };
}
