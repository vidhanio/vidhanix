let
  pkg =
    {
      lib,
      fetchFromGitHub,
      rustPlatform,
      vimUtils,
      nix-update-script,
    }:
    let
      version = "0.4.6-beta.1";

      src = fetchFromGitHub {
        owner = "sheng-tse";
        repo = "jupynvim";
        tag = "v${version}";
        hash = "sha256-ZPUIUFRmuSC73H2pCf/H89XNSKC9MN2E6zUWhePjSIg=";
      };

      core = rustPlatform.buildRustPackage {
        pname = "jupynvim-core";
        inherit version src;

        cargoRoot = "core";
        buildAndTestSubdir = "core";
        cargoHash = "sha256-X2ukj5vVrQBBa96xg/tW3w8QyJyZCUoj8lHIS3idhNg=";

        meta = {
          description = "Native backend for jupynvim";
          mainProgram = "jupynvim-core";
          homepage = "https://github.com/sheng-tse/jupynvim";
          license = lib.licenses.mit;
          platforms = lib.platforms.unix;
        };
      };
    in
    vimUtils.buildVimPlugin {
      pname = "jupynvim";
      inherit version src;

      postInstall = ''
        mkdir -p $out/bin
        install -m755 ${lib.getExe core} $out/bin/jupynvim-core
      '';

      passthru = {
        # Exposed so `nix-update` can refresh the core's vendored cargo hash.
        inherit (core) cargoDeps;

        updateScript = nix-update-script {
          extraArgs = [
            "--flake"
            "--version=unstable"
          ];
        };
      };

      meta = {
        description = "VSCode-style Jupyter notebook editing in Neovim";
        mainProgram = "jupynvim-core";
        homepage = "https://github.com/sheng-tse/jupynvim";
        changelog = "https://github.com/sheng-tse/jupynvim/releases/tag/v${version}";
        license = lib.licenses.mit;
        platforms = lib.platforms.unix;
      };
    };
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.jupynvim = pkgs.callPackage pkg { };
    };
}
