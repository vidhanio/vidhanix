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

      postPatch = ''
        substituteInPlace lua/jupynvim/notebook/render.lua \
          --replace-fail 'local ltxt = vim.api.nvim_buf_get_lines(buf, out_last, out_last + 1, false)[1] or ""' \
          'for row = range.out_sep + 1, out_last do
            vim.api.nvim_buf_set_extmark(buf, nb.border_ns, row, 0, {
              line_hl_group = "JupynvimOutputBackground",
              priority = 4999,
            })
          end
          local ltxt = vim.api.nvim_buf_get_lines(buf, out_last, out_last + 1, false)[1] or ""'
      '';

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
