{
  perSystem =
    {
      lib,
      pkgs,
      system,
      ...
    }:
    {
      packages = lib.optionalAttrs (system == "aarch64-linux") {
        millennium-arm64 = pkgs.millennium.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [
            ./steamrt-arm64.patch
            ./snare-arm64.patch
          ];

          # X64 selects the SteamRT3 build; the compiler still targets AArch64.
          cmakeFlags = old.cmakeFlags ++ [ (lib.cmakeBool "MILLENNIUM_LINUX_X64" true) ];
          meta = old.meta // {
            platforms = [ "aarch64-linux" ];
          };
        });
      };
    };
}
