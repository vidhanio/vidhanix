{
  flake.aspects.boot = {
    nixos =
      { pkgs, ... }:
      {
        boot.binfmt.emulatedSystems = builtins.filter (system: system != pkgs.stdenv.hostPlatform.system) [
          "aarch64-linux"
          "x86_64-linux"
        ];
      };
  };
}
