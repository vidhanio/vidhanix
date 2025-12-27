let
  pkg =
    {
      lib,
      appimageTools,
      _experimental-update-script-combinators,
      nix-update-script,
      fetchurl,
      stdenvNoCC,

      helium-appimage-x86_64-linux,
      helium-appimage-aarch64-linux,
    }:
    let
      inherit (stdenvNoCC.hostPlatform) system;

      platforms = {
        x86_64-linux = helium-appimage-x86_64-linux;
        aarch64-linux = helium-appimage-aarch64-linux;
      };

      inherit (platforms.${system} or (throw "Unsupported system: ${system}")) src;
    in
    appimageTools.wrapType2 rec {
      pname = "helium";
      version = "0.7.7.1";

      inherit src;

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
          substituteInPlace $out/share/applications/${pname}.desktop --replace-fail 'Exec=AppRun' 'Exec=${meta.mainProgram}'
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
    {
      config,
      pkgs,
      ...
    }:
    {
      packages.helium-bin = pkgs.callPackage pkg { };
    };
}
