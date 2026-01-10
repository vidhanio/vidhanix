{
  flake.modules.nixos.default =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        wl-clipboard
      ];
    };
}
