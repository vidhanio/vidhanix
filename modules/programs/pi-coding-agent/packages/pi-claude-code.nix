let
  pkg =
    {
      claude-code,
      fetchFromGitHub,
      lib,
      nix-update-script,
      stdenvNoCC,
    }:
    stdenvNoCC.mkDerivation {
      pname = "pi-claude-code";
      version = "0.1.0";

      src = fetchFromGitHub {
        owner = "earendil-works";
        repo = "pi-claude-code";
        rev = "70abb65186592ca788b29b3db22c3160d629c41f";
        hash = "sha256-9BHTz/IRf8jZczVYoXtypepBDmWJ9+5id6hwZUdeSV0=";
      };

      dontBuild = true;

      installPhase = ''
        runHook preInstall

        mkdir -p "$out/lib/node_modules/pi-claude-code"
        cp -r src package.json README.md ARCHITECTURE.md LICENSE "$out/lib/node_modules/pi-claude-code/"

        substituteInPlace "$out/lib/node_modules/pi-claude-code/src/claude-cli.ts" \
          --replace-fail 'env.PI_CLAUDE_CODE_COMMAND || "claude"' \
          'env.PI_CLAUDE_CODE_COMMAND || "${lib.getExe claude-code}"'

        runHook postInstall
      '';

      passthru.updateScript = nix-update-script {
        extraArgs = [
          "--flake"
          "--version=unstable"
        ];
      };

      meta = {
        description = "Experimental pi provider for Claude Pro/Max subscriptions through Claude Code";
        homepage = "https://github.com/earendil-works/pi-claude-code";
        license = lib.licenses.mit;
        platforms = lib.platforms.all;
      };
    };
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.pi-claude-code = pkgs.callPackage pkg { };
    };
}
