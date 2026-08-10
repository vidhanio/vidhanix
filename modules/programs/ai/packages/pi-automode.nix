let
  pkg =
    {
      lib,
      fetchFromGitHub,
      stdenv,
      nix-update-script,
    }:
    stdenv.mkDerivation (finalAttrs: {
      pname = "pi-automode";
      version = "1.11.0";

      src = fetchFromGitHub {
        owner = "czottmann";
        repo = "pi-automode";
        tag = "v${finalAttrs.version}";
        hash = "sha256-A5KyQTuHLn7MGNaZbxjsaO1AkcyWLcrnJiGAawd5jV8=";
      };

      dontBuild = true;
      dontConfigure = true;

      patches = [ ./disable-statusline.patch ];

      installPhase = ''
        runHook preInstall

        mkdir -p $out
        cp -r extensions $out/extensions

        runHook postInstall
      '';

      passthru.updateScript = nix-update-script {
        extraArgs = [ "--flake" ];
      };

      meta = {
        description = "Claude Code-style auto mode guardrail extension for Pi";
        homepage = "https://github.com/czottmann/pi-automode";
        changelog = "https://github.com/czottmann/pi-automode/releases/tag/${finalAttrs.src.tag}";
        license = lib.licenses.mit;
        platforms = lib.platforms.all;
      };
    });
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.pi-automode = pkgs.callPackage pkg { };
    };
}
