{
  lib,
  stdenvNoCC,
  cacert,
  curl,
  unzip,
}:
{
  group,
  ext,
  system,
  game,
  hash,
}:
stdenvNoCC.mkDerivation {
  name = "${game}.${ext}";

  SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  buildInputs = [
    curl
    unzip
  ];

  url = "https://myrient.erista.me/files/${lib.escapeURL group}/${lib.escapeURL system}/${lib.escapeURL game}.zip";
  filename = "${game}.${ext}";

  builder = ./builder.sh;

  outputHash = hash;
  outputHashAlgo = if hash == "" then "sha1" else null;
  outputHashMode = "flat";
}
