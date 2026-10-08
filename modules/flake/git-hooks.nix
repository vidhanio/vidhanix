{ inputs, lib, ... }:
{
  imports = [
    inputs.git-hooks-nix.flakeModule
  ];
  perSystem =
    { pkgs, ... }:
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
      files.gitignore = ".pre-commit-config.yaml";

      pre-commit.settings = {
        package = pkgs.prek;
        hooks = {
          codebook = {
            enable = true;
            package = codebookPackage;
            entry = lib.getExe codebookPackage;
            args = [ "lint" ];
            types = [ "text" ];
            excludes = [ "^secrets\\.yaml$" ];
          };
          deadnix.enable = true;
          harper = {
            enable = true;
            package = pkgs.harper;
            entry = lib.getExe' pkgs.harper "harper-cli";
            args = [
              "lint"
              "--user-dict-path"
              ".harper-dictionary.txt"
              "--ignore"
              (lib.concatStringsSep "," [
                "ExpandArgument"
                "ExpandConfiguration"
                "ExpandDirectory"
                "ExpandMemoryShorthands"
                "ExpandMinimum"
                "ExpandTimeShorthands"
                "ToDoHyphen"
                "UseTitleCase"
              ])
            ];
            files = "\\.(md|nix|py|sh|lua)$";
            types = [ "text" ];
          };
          ruff.enable = true;
          shellcheck.enable = true;
          statix.enable = true;
          treefmt.enable = true;
          ty = {
            enable = true;
            name = "ty";
            entry = "${lib.getExe pkgs.ty} check --python ${
              lib.getExe (pkgs.python3.withPackages (ps: [ ps.rich ]))
            }";
            types = [ "python" ];
          };
        };
      };
    };
}
