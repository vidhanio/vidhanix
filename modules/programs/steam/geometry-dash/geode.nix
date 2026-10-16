let
  pkg =
    {
      lib,
      stdenvNoCC,
      fetchurl,
      unzip,
      nix-update-script,
    }:
    stdenvNoCC.mkDerivation (finalAttrs: {
      pname = "geode";
      version = "5.11.2";

      src = fetchurl {
        url = "https://github.com/geode-sdk/geode/releases/download/v${finalAttrs.version}/geode-v${finalAttrs.version}-win.zip";
        hash = "sha256-GT1NkAPdAgyYnq5cDlNFqltQHyo+pGfr3YO3KgxlOc8=";
      };

      nativeBuildInputs = [ unzip ];
      sourceRoot = ".";
      dontBuild = true;
      dontStrip = true;
      dontPatchELF = true;

      installPhase = ''
        runHook preInstall

        install -Dm644 Geode.dll "$out/Geode.dll"
        install -Dm644 XInput1_4.dll "$out/XInput1_4.dll"
        install -Dm755 GeodeUpdater.exe "$out/GeodeUpdater.exe"

        runHook postInstall
      '';

      passthru.updateScript = nix-update-script {
        extraArgs = [ "--flake" ];
      };

      meta = {
        description = "Geometry Dash mod loader for Windows and Proton";
        homepage = "https://geode-sdk.org/";
        changelog = "https://github.com/geode-sdk/geode/releases/tag/v${finalAttrs.version}";
        license = lib.licenses.boost;
        platforms = lib.platforms.linux;
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
      };
    });
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.geode = pkgs.callPackage pkg { };
    };
}
