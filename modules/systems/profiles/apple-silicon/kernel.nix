let
  pkg =
    {
      callPackage,
      curl,
      git,
      fetchpatch,
      gnused,
      jq,
      lib,
      linux-asahi,
      linuxPackagesFor,
      nix-prefetch-github,
      symlinkJoin,
      writeShellScript,
      _kernelPatches ? [ ],
    }@args:
    let
      extraArgs = lib.removeAttrs args [
        "callPackage"
        "curl"
        "fetchpatch"
        "git"
        "gnused"
        "jq"
        "lib"
        "linux-asahi"
        "linuxPackagesFor"
        "nix-prefetch-github"
        "symlinkJoin"
        "writeShellScript"
        "_kernelPatches"
      ];
      linuxFairydustPkg =
        {
          stdenv,
          lib,
          buildLinux,
          fetchFromGitHub,
          ...
        }:
        buildLinux (
          lib.recursiveUpdate rec {
            inherit stdenv lib;
            pname = "linux-asahi-fairydust";
            version = "7.1.13";
            modDirVersion = version;
            extraMeta = {
              branch = "7.1";
              description = "Experimental Asahi Linux kernel with DisplayPort Alt Mode support";
              homepage = "https://github.com/AsahiLinux/linux/tree/fairydust";
              license = lib.licenses.gpl2Only;
              platforms = [ "aarch64-linux" ];
            };
            src = fetchFromGitHub {
              owner = "AsahiLinux";
              repo = "linux";
              rev = "ce9f2eba72c061a50b2d790450e90af3439d8c24";
              hash = "sha256-W3yMSUe6xa+M/X0k86kbCS4g3d7jJmO3WV9L/5rQRhI=";
            };
            kernelPatches =
              linux-asahi.kernelPatches
              ++ [
                {
                  name = "brcmfmac-report-port-authorized";
                  patch = fetchpatch {
                    url = "https://patchwork.kernel.org/project/linux-wireless/patch/20260912-brcmfmac-4way-handshake-offload-authenticated-event-v1-1-e41a6a8281a2@jannau.net/raw/";
                    hash = "sha256-7kjcbhCOjGpGpBzQlyhbVvJtM+uLV90AhUuRXLZPPT8=";
                  };
                }
              ]
              ++ _kernelPatches;
          } extraArgs
        );
      kernel = callPackage linuxFairydustPkg { };
      wrapper = symlinkJoin {
        inherit (kernel) pname src version;
        paths = [ kernel ];
        passthru = {
          inherit kernel;
          updateScript =
            let
              curlExe = lib.getExe curl;
              gitExe = lib.getExe git;
              jqExe = lib.getExe jq;
              nixPrefetchGitHubExe = lib.getExe nix-prefetch-github;
              sedExe = lib.getExe gnused;
            in
            writeShellScript "update-linux-asahi-fairydust" ''
              set -euo pipefail

              package_file=modules/systems/profiles/apple-silicon/kernel.nix
              remote_ref="$(${gitExe} ls-remote --exit-code --heads https://github.com/AsahiLinux/linux.git fairydust)"
              rev="$(printf '%s\n' "$remote_ref" | ${sedExe} -n 's/^\([0-9a-f]\{40\}\)[[:space:]].*/\1/p')"
              current_rev="$(${sedExe} -n -E 's/^[[:space:]]*rev = "([0-9a-f]+)";/\1/p' "$package_file")"

              if [[ ! "$rev" =~ ^[0-9a-f]{40}$ ]]; then
                echo "invalid fairydust revision: $rev" >&2
                exit 1
              fi

              if [[ "$rev" == "$current_rev" ]]; then
                exit 0
              fi

              metadata="$(${nixPrefetchGitHubExe} AsahiLinux linux --rev "$rev")"
              rev="$(${jqExe} --raw-output .rev <<<"$metadata")"
              hash="$(${jqExe} --raw-output .hash <<<"$metadata")"
              makefile="$(${curlExe} --fail --silent --show-error --location "https://raw.githubusercontent.com/AsahiLinux/linux/$rev/Makefile")"

              makefile_value() {
                printf '%s\n' "$makefile" | ${sedExe} -n "s/^$1 = //p"
              }

              kernel_version="$(makefile_value VERSION).$(makefile_value PATCHLEVEL).$(makefile_value SUBLEVEL)"
              if [[ ! "$kernel_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                echo "invalid kernel version: $kernel_version" >&2
                exit 1
              fi

              ${sedExe} --in-place --regexp-extended \
                -e 's/version = "[^"]+";/version = "'"$kernel_version"'";/' \
                -e 's/rev = "[0-9a-f]+";/rev = "'"$rev"'";/' \
                -e 's|hash = "sha256-[^"]+";|hash = "'"$hash"'";|' \
                "$package_file"
            '';
        };
        inherit (kernel) meta;
      };
    in
    lib.recurseIntoAttrs ((linuxPackagesFor kernel) // { inherit wrapper; });
in
{
  perSystem =
    { inputs', pkgs, ... }:
    {
      packages = {
        linux-asahi-fairydust =
          (pkgs.callPackage pkg {
            linux-asahi = inputs'.nixos-apple-silicon.packages.linux-asahi;
          }).wrapper;
      };
    };
}
