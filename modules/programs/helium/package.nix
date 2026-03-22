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

      platforms = {
        x86_64-linux = {
          os = "x86_64";
          hash = "sha256-6xqNRaP3aqitEseexRVEEjKkJClC0j1HHZoRGQanhSk=";
        };
        aarch64-linux = {
          os = "arm64";
          hash = "sha256-2SDIEni0A3aVqABoaSB7qDyBUfllAc3V6EbGQf+VUAk=";
        };
      };

      inherit (platforms.${system} or (throw "Unsupported system: ${system}")) os hash;
    in
    appimageTools.wrapType2 rec {
      pname = "helium";
      version = "0.10.6.1";

      src = fetchurl {
        url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-${os}.AppImage";
        inherit hash;
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

      extraInstallCommands =
        let
          contents = appimageTools.extractType2 { inherit pname version src; };
        in
        ''
          mkdir -p "$out/share/applications"
          mkdir -p "$out/share/lib/helium"
          cp -r ${contents}/opt/helium/locales "$out/share/lib/helium"
          cp -r ${contents}/usr/share/* "$out/share"
          cp "${contents}/${pname}.desktop" "$out/share/applications/"
        '';

      meta = {
        description = "Private, fast, and honest web browser based on Chromium";
        homepage = "https://github.com/imputnet/helium-chromium";
        changelog = "https://github.com/imputnet/helium-linux/releases/tag/${version}";
        platforms = lib.attrNames platforms;
        license = lib.licenses.gpl3;
        mainProgram = "helium";
      };
    };
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.helium-bin = pkgs.callPackage pkg { };
    };
}
