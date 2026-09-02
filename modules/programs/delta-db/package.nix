let
  pkg =
    {
      lib,
      stdenv,
      requireFile,
      autoPatchelfHook,
      makeWrapper,
      libGL,
      libxcb,
      libx11,
      libxau,
      libxdmcp,
      vulkan-loader,
      wayland,
      xkeyboard_config,
    }:
    let
      sources = {
        aarch64-linux = {
          name = "delta-linux-aarch64.tar.gz";
          hash = "sha256-Rg9KBSSmUR3LJIDp4F6dOnEX5zhcLVtmXJjPupvsNcc=";
        };
        x86_64-linux = {
          name = "delta-linux-x86_64.tar.gz";
          hash = "sha256-suIRakJGD7O6eyJmyceERZlFJ7tNQW7Z2gfiHcEryoI=";
        };
      };
      source = sources.${stdenv.hostPlatform.system};
    in
    stdenv.mkDerivation {
      pname = "delta-db";
      version = "0.4.0";

      src = requireFile {
        inherit (source) name hash;
        message = ''
          Delta downloads require a GitHub-authenticated account.

          1. Download ${source.name} from https://delta.dev/download
          2. Add it to the Nix store with:
             nix-store --add-fixed sha256 ${source.name}
        '';
      };

      sourceRoot = "Delta";
      dontBuild = true;

      nativeBuildInputs = [
        autoPatchelfHook
        makeWrapper
      ];

      buildInputs = lib.optionals stdenv.hostPlatform.isAarch64 [
        libxcb
        libxau
        libxdmcp
      ];

      appendRunpaths = [
        (lib.makeLibraryPath [
          libGL
          vulkan-loader
          wayland
        ])
      ];

      installPhase = ''
        runHook preInstall

        mkdir -p "$out"
        cp -r bin lib share "$out/"

        runHook postInstall
      '';

      postFixup = ''
        wrapProgram "$out/bin/delta" \
          --set DELTA_UPDATE_EXPLANATION "Delta has been installed using Nix. Auto-updates have thus been disabled." \
          --set XKB_CONFIG_ROOT "${xkeyboard_config}/share/X11/xkb" \
          --set XLOCALEDIR "${libx11}/share/X11/locale"
      '';

      meta = {
        description = "AI-native coding environment by the creators of Zed";
        homepage = "https://delta.dev/";
        downloadPage = "https://delta.dev/download";
        license = lib.licenses.unfree;
        mainProgram = "delta";
        platforms = builtins.attrNames sources;
        sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      };
    };
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.delta-db = pkgs.callPackage pkg { };
    };
}
