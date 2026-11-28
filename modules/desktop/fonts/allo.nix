{
  perSystem =
    { pkgs, ... }:
    {
      packages.allo = pkgs.callPackage (
        {
          lib,
          stdenvNoCC,
          fetchFromGitHub,
          python3,
          installFonts,
          nix-update-script,
        }:
        stdenvNoCC.mkDerivation (finalAttrs: {
          pname = "allo";
          version = "1.1.1";

          src = fetchFromGitHub {
            owner = "joshpuckett";
            repo = "allo";
            tag = "v${finalAttrs.version}";
            hash = "sha256-NsQsnbz3Vtles3eityzGkSww71ZhNQPBNk3AxXTtU0U=";
          };

          outputs = [
            "out"
            "webfont"
          ];

          nativeBuildInputs = [
            (python3.withPackages (
              ps: with ps; [
                afdko
                brotli
                cffsubr
                fonttools
                ufo2ft
                ufolib2
              ]
            ))
            installFonts
          ];

          postPatch = ''
            rm -r fonts
          '';

          buildPhase = ''
            runHook preBuild

            python3 build.py

            runHook postBuild
          '';

          preInstall = ''
            cd fonts
          '';

          passthru.updateScript = nix-update-script { };

          meta = {
            description = "Friendly variable font family with weight, roundness, and optical size axes";
            homepage = "https://allo.joshpuckett.me/";
            changelog = "https://github.com/joshpuckett/allo/releases/tag/${finalAttrs.src.tag}";
            license = lib.licenses.ofl;
            platforms = lib.platforms.all;
          };
        })
      ) { };
    };
}
