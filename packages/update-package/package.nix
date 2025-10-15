{
  lib,
  writeText,
  stdenvNoCC,
  nix,
  jq,
  nix-update,
  installShellFiles,
  writeShellApplication,
}:

let
  inherit (stdenvNoCC.hostPlatform) system;

  update-package = writeShellApplication {
    name = "update-package";

    runtimeInputs = [ nix-update ];

    text = ''
      if [ "$#" -ne 1 ]; then
        echo "usage: update-package <package-name>"
        exit 1
      fi

      package_name=$1

      nix-update --flake -u --build "$package_name"
    '';
  };

  fish-completions = writeText "update-package.fish" ''
    complete -c update-package \
      --no-files \
      -d 'Package' \
      -a '(${lib.getExe nix} eval --json .#packages.${system} --apply builtins.attrNames 2>/dev/null | ${lib.getExe jq} -r ".[]")'
  '';
in
stdenvNoCC.mkDerivation {
  name = "update-package";

  nativeBuildInputs = [ installShellFiles ];

  phases = [ "installPhase" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ${lib.getExe update-package} $out/bin/update-package

    installShellCompletion --cmd update-package --fish ${fish-completions}

    runHook postInstall
  '';
}
