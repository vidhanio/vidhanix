{
  flake-file.nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://vidhanio.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "vidhanio.cachix.org-1:Qzk2G10fmck+K+pxP5nvHC5yl/ic315by091/bJpnio="
    ];
  };
}
