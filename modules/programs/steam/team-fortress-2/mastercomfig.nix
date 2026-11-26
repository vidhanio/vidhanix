let
  pkg =
    {
      lib,
      stdenvNoCC,
      fetchFromGitHub,
      nix-update-script,
      python3,
      writeShellScriptBin,
      zip,
    }:
    let
      python = python3.withPackages (ps: [ ps.vpk ]);
      src = fetchFromGitHub {
        owner = "mastercomfig";
        repo = "mastercomfig";
        rev = "b38ae17b2e1dc61d84ac02f1123f5ee000b1fc15";
        hash = "sha256-RsP/8pDX1/fI91Dt5PpQy8uEU/lELEl8Q54rfBoXE3A=";
      };
      vpk = writeShellScriptBin "vpk" ''
        exec ${python}/bin/python3 ${src}/dev/vpk_cli.py "$@"
      '';
    in
    stdenvNoCC.mkDerivation {
      pname = "mastercomfig";
      version = "dev-unstable-2026-11-22";

      inherit src;

      nativeBuildInputs = [
        vpk
        python
        zip
      ];

      postPatch = ''
        patchShebangs dev
      '';

      buildPhase = ''
        runHook preBuild

        ./dev/package.sh

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        install -Dm644 -t "$out/addons" dev/addons/*.vpk
        install -Dm644 -t "$out/comfig" dev/comfig/autoexec.cfg dev/comfig/autoexec_template.cfg
        install -Dm644 dev/presets/mastercomfig-base.vpk "$out/presets/mastercomfig-base.vpk"
        install -Dm644 dev/template/template.zip "$out/template/template.zip"

        runHook postInstall
      '';

      passthru.updateScript = nix-update-script {
        extraArgs = [ "--version=branch" ];
      };

      meta = {
        description = "Team Fortress 2 performance and customization config";
        homepage = "https://github.com/mastercomfig/mastercomfig";
        license = lib.licenses.mit;
        platforms = lib.platforms.linux;
      };
    };
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.mastercomfig = pkgs.callPackage pkg { };
    };
}
