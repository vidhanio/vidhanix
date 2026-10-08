{ inputs, lib, ... }:
{
  imports = [
    inputs.hk-nix.flakeModules.default
  ];
  perSystem =
    { config, pkgs, ... }:
    let
      dictionaryRepo = pkgs.fetchFromGitHub {
        owner = "streetsidesoftware";
        repo = "cspell-dicts";
        rev = "7ed1c944f90e16097033bf320e5359dfd25ba236";
        hash = "sha256-fGhISlvTaN3/twWaZflmebFQ2y3V2y+w+gijE8cZA/8=";
      };
      codebookWithDicts =
        dictPaths:
        pkgs.symlinkJoin {
          name = "codebook-with-dictionaries-${pkgs.codebook.version}";
          paths = [ pkgs.codebook ];
          nativeBuildInputs = [
            pkgs.jq
            pkgs.makeWrapper
          ];
          postBuild = ''
            cache="$out/share/codebook/cache"
            mkdir -p "$cache"
            : > "$cache/entries.json"
            ${lib.concatMapStringsSep "\n" (path: ''
              mkdir -p "$cache"/${lib.escapeShellArg (builtins.dirOf path)}
              cp ${dictionaryRepo}/dictionaries/${lib.escapeShellArg path} "$cache"/${lib.escapeShellArg path}
              jq --null-input \
                --arg url ${lib.escapeShellArg "https://raw.githubusercontent.com/streetsidesoftware/cspell-dicts/refs/heads/main/dictionaries/${path}"} \
                --arg path "$cache"/${lib.escapeShellArg path} \
                --arg hash "$(sha256sum "$cache"/${lib.escapeShellArg path} | cut -d ' ' -f 1)" \
                '{key: $url, value: {path: $path, content_hash: $hash,
                  last_checked: "1970-01-01T00:00:00Z", last_modified: null}}' >> "$cache/entries.json"
            '') dictPaths}
            jq --slurp '{files: from_entries}' "$cache/entries.json" > "$cache/_metadata.json"
            rm "$cache/entries.json"
            wrapProgram "$out/bin/codebook-lsp" \
              --set XDG_DATA_HOME "$out/share" \
              --set NO_NETWORK 1
          '';
          meta = pkgs.codebook.meta;
        };
      codebookPackage = codebookWithDicts [
        "csharp/dict/csharp.txt"
        "dart/dict/dart.txt"
        "en_US/src/hunspell/en_US-large.aff"
        "en_US/src/hunspell/en_US-large.dic"
        "golang/dict/go.txt"
        "rust/dict/rust.txt"
        "software-terms/dict/computing-acronyms.txt"
        "software-terms/dict/softwareTerms.txt"
      ];
    in
    {
      hk-nix.settings.hooks."pre-commit" = {
        fix = true;
        stage = false;
        fail_on_fix = true;
        stash = "git";
        steps = {
          codebook = {
            types = [ "text" ];
            exclude = [ "secrets.yaml" ];
            check = "${lib.getExe codebookPackage} lint {{files}}";
          };
          deadnix = {
            glob = "**/*.nix";
            check = "${lib.getExe pkgs.deadnix} --fail {{files}}";
          };
          harper = {
            glob = "**/*.{md,nix,py,sh,lua}";
            check = "${lib.getExe' pkgs.harper "harper-cli"} lint --user-dict-path .harper-dictionary.txt --ignore ${
              lib.concatStringsSep "," [
                "ExpandArgument"
                "ExpandConfiguration"
                "ExpandDirectory"
                "ExpandMemoryShorthands"
                "ExpandMinimum"
                "ExpandTimeShorthands"
                "ToDoHyphen"
                "UseTitleCase"
              ]
            } {{files}}";
          };
          ruff = {
            types = [ "python" ];
            check = "${lib.getExe pkgs.ruff} check {{files}}";
            fix = "${lib.getExe pkgs.ruff} check --fix {{files}}";
          };
          shellcheck = {
            match_any = [
              { __pkl = ''new FileSelector { types = List("shell") }''; }
              { __pkl = ''new FileSelector { glob = ".envrc" }''; }
            ];
            check = "${lib.getExe pkgs.shellcheck} {{files}}";
          };
          statix = {
            glob = "**/*.nix";
            check = "${lib.getExe pkgs.statix} check";
          };
          treefmt = {
            check = "${lib.getExe config.treefmt.build.wrapper} --fail-on-change --no-cache {{files}}";
            fix = "${lib.getExe config.treefmt.build.wrapper} --no-cache {{files}}";
          };
          ty = {
            types = [ "python" ];
            check = "${lib.getExe pkgs.ty} check --python ${
              lib.getExe (pkgs.python3.withPackages (ps: [ ps.rich ]))
            } {{files}}";
          };
          write-files = {
            depends = [ "treefmt" ];
            stage = lib.attrNames config.files.file;
            check = lib.getExe (
              pkgs.writeShellApplication {
                name = "check-generated-files";
                runtimeInputs = [ pkgs.diffutils ];
                text = lib.concatStringsSep "\n" (
                  lib.mapAttrsToList (
                    path: file: "diff --unified ${lib.escapeShellArg path} ${file.source}"
                  ) config.files.file
                );
              }
            );
            fix = lib.getExe config.files.writer.drv;
          };
        };
      };
    };
}
