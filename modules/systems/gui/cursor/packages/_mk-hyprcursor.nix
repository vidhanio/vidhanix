{
  lib,
  stdenvNoCC,
  hyprcursor,
  writeTextFile,
  xcur2png,
}:
lib.makeOverridable (
  {
    xcursor,
    themeName,
    pname ? "${xcursor.pname}-hyprcursor",
    version ? xcursor.version,
    src ? null,
    extraNativeBuildInputs ? [ ],
    postExtract ? "",
    meta ? xcursor.meta // {
      description = "${themeName} converted to hyprcursor";
    },
    description ? meta.description,
  }:
  stdenvNoCC.mkDerivation (
    {
      inherit
        pname
        version
        postExtract
        meta
        ;

      nativeBuildInputs = [
        hyprcursor
        xcur2png
      ]
      ++ extraNativeBuildInputs;

      buildPhase = ''
        runHook preBuild

        themeName=${lib.escapeShellArg themeName}
        extractedTheme="extracted_$themeName"
        hyprcursor-util -x "${xcursor}/share/icons/$themeName" -o .

        cp ${
          writeTextFile {
            name = "manifest.hl";
            text = ''
              name = ${themeName}
              description = ${description}
              version = ${version}
              cursors_directory = hyprcursors
            '';
          }
        } "$extractedTheme/manifest.hl"

        runHook postExtract
        hyprcursor-util -c "$extractedTheme"

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p "$out/share/icons"
        cp -r "theme_$themeName" "$out/share/icons/$themeName"

        runHook postInstall
      '';
    }
    // (if src == null then { dontUnpack = true; } else { inherit src; })
  )
)
