final: prev:
let
  inherit (prev) lib stdenv;
in
{
  solaar = prev.solaar.overrideAttrs (
    finalAttrs: previousAttrs: {
      version = "1.1.16";
      src = previousAttrs.src.override {
        tag = finalAttrs.version;
        hash = "sha256-PhZoDRsckJXk2t2qR8O3ZGGeMUhmliqSpibfQDO7BeA=";
      };
      buildInputs = previousAttrs.buildInputs ++ [ final.upower ];

      postInstall = previousAttrs.postInstall or "" + ''
        cp $src/share/autostart/solaar.desktop $out/share/applications/solaar-autostart.desktop
      '';
    }
  );
}
// lib.optionalAttrs stdenv.hostPlatform.isAarch64 {
  wrapFirefox =
    browser: opts:
    let
      extraPrefs = opts.extraPrefs or "" + ''
        lockPref("media.gmp-widevinecdm.version", "system-installed");
        lockPref("media.gmp-widevinecdm.visible", true);
        lockPref("media.gmp-widevinecdm.enabled", true);
        lockPref("media.gmp-widevinecdm.autoupdate", false);
        lockPref("media.eme.enabled", true);
        lockPref("media.eme.encrypted-media-encryption-scheme.enabled", true);
      '';

      widevineCdmDir = "${final.widevine-cdm}/share/google/chrome/WidevineCdm";
      widevineOutDir = "$out/gmp-widevinecdm/system-installed";
    in
    (prev.wrapFirefox browser (opts // { inherit extraPrefs; })).overrideAttrs (previousAttrs: {
      buildCommand = previousAttrs.buildCommand + ''
        mkdir -p "${widevineOutDir}"
        ln -s "${widevineCdmDir}/_platform_specific/linux_arm64/libwidevinecdm.so" "${widevineOutDir}/libwidevinecdm.so"
        ln -s "${widevineCdmDir}/manifest.json" "${widevineOutDir}/manifest.json"
        wrapProgram "$oldExe" --set MOZ_GMP_PATH "${widevineOutDir}"
      '';
    });
}
