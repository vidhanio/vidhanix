let
  pkg =
    {
      lib,
      fetchurl,
      python3,
      stdenvNoCC,
    }:
    stdenvNoCC.mkDerivation {
      pname = "arete-27b-mtp-gguf";
      version = "0-unstable-2026-11-07";

      base = fetchurl {
        url = "https://huggingface.co/mradermacher/Arete-27B-i1-GGUF/resolve/e00aa8fd159e2fff4cd8153ece907f9527253cc1/Arete-27B.i1-IQ3_XS.gguf";
        hash = "sha256-PtclyTnH6sm2PiXTm5NtsN1K9odqTIdQoBwRPf6XriI=";
      };
      # Arete ships without the MTP head, so borrow the base model's.
      donor = fetchurl {
        url = "https://huggingface.co/byteshape/Qwen3.8-27B-GGUF/resolve/3fdfbd9b4a618303ad36edb151e95d134ece8c18/Qwen3.8-27B-IQ3_XS-3.01bpw.gguf";
        hash = "sha256-gw7sLQ//ntgspUouJVe/uibsiI/KRzrLLI6adbQCGg0=";
      };

      nativeBuildInputs = [ (python3.withPackages (ps: [ ps.gguf ])) ];
      dontUnpack = true;
      dontFixup = true;
      preferLocalBuild = true;
      allowSubstitutes = false;

      installPhase = ''
        runHook preInstall
        python ${./graft-mtp.py} "$base" "$donor" "$out"
        runHook postInstall
      '';

      meta = {
        description = "Arete-27B IQ3_XS GGUF with the Qwen3.8-27B MTP head for speculative decoding";
        homepage = "https://huggingface.co/NousResearch/Arete-27B";
        license = lib.licenses.asl20;
        platforms = lib.platforms.all;
      };
    };
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.arete-27b-mtp-gguf = pkgs.callPackage pkg { };
    };
}
