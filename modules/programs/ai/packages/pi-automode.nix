let
  pkg =
    {
      lib,
      fetchurl,
      stdenv,
      nix-update-script,
    }:
    stdenv.mkDerivation (finalAttrs: {
      pname = "pi-automode";
      version = "1.11.0";

      src = fetchurl {
        url = "https://registry.npmjs.org/@czottmann/pi-automode/-/pi-automode-${finalAttrs.version}.tgz";
        hash = "sha256-ICD8lGznbBkQ/2+BA4NtIiQ4YyFckrt+2bdPS6kk1fU=";
      };

      dontBuild = true;
      dontConfigure = true;

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
        homepage = "https://pi.dev/packages/@czottmann/pi-automode";
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
