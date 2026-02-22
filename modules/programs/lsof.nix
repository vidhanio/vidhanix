{
  flake.modules.nixos.default =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.lsof ];
    };
}
