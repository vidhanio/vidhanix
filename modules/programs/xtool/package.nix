let
  pkg =
    {
      lib,
      appimageTools,
      _experimental-update-script-combinators,
      nix-update-script,
      fetchurl,
      stdenv,
    }:
    let
      inherit (stdenv.hostPlatform) system;

      pname = "xtool";
      version = "1.16.1";

      platforms = {
        x86_64-linux = {
          url = "https://github.com/xtool-org/xtool/releases/download/${version}/xtool-x86_64.AppImage";
          hash = "sha256-VqrJE3KYDSw3/eslzbfm+C2V3qQ51aama5dNpIBNLQk=";
        };
        aarch64-linux = {
          url = "https://github.com/xtool-org/xtool/releases/download/${version}/xtool-aarch64.AppImage";
          hash = "sha256-RGG1zmoAw7Otmd/cMRkYy7AgIGmHkNSdLs7T7282a5s=";
        };
      };

      inherit (platforms.${system} or (throw "Unsupported system: ${system}")) url hash;
    in
    appimageTools.wrapType2 {
      inherit pname version;

      src = fetchurl {
        inherit url hash;
      };

      passthru.updateScript = _experimental-update-script-combinators.sequence [
        (nix-update-script {
          extraArgs = [
            "--flake"
            "--system=x86_64-linux"
          ];
        })
        (nix-update-script {
          extraArgs = [
            "--flake"
            "--system=aarch64-linux"
            "--version=skip"
          ];
        })
      ];

      extraPkgs = pkgs: [
        pkgs.swift
        pkgs.unzip
        pkgs.usbmuxd
      ];

      meta = {
        description = "Cross-platform Xcode replacement";
        homepage = "https://xtool.sh";
        changelog = "https://github.com/xtool-org/xtool/releases/tag/${version}";
        license = lib.licenses.mit;
        sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
        maintainers = [ ];
        mainProgram = "xtool";
        platforms = lib.attrNames platforms;
      };
    };
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.xtool-bin = pkgs.callPackage pkg { };
    };
}
