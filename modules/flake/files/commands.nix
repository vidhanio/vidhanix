{
  perSystem =
    _:
    let
      vars = {
        host = "`hostname`";
        user = "`whoami`";
        nixosConfig = ''".#nixosConfigurations." + host + ".config"'';
        hmConfig = ''nixosConfig + ".home-manager.users." + user'';
        systemPackage = ''nixosConfig + ".system.build.toplevel"'';
        system = "`nix eval --raw --impure --expr 'builtins.currentSystem'`";
        perSystemConfig = ''".#allSystems." + system + ".config"'';
      };

      add = {
        doc = "record the intent to add each new file, so that the flake sees it";
        silent = true;
        body = "git add -AN";
      };

      fmt = {
        doc = "format the tree with treefmt, e.g. `just fmt --ci`";
        silent = true;
        args = [ "*flags" ];
        dependencies = [ "add" ];
        body = "nix fmt -- {{ flags }}";
      };

      # Private copy of a shared recipe; the root justfile keeps the original.
      mkPrivate = recipe: recipe // { attrs = [ "private" ]; };

      # `prefix` = installable before `.<option>`; `path` = just expr for the installable.
      mkEvalTree = doc: prefix: {
        inherit doc;
        silent = true;
        args = [
          "option"
          "*flags"
        ];
        dependencies = [ "add" ];
        body = "nix eval {{ flags }} ${prefix}.{{ option }}";
      };

      mkBuildTree = doc: path: {
        inherit doc;
        silent = true;
        args = [
          "option"
          "*flags"
        ];
        dependencies = [ "(flake ${path} flags)" ];
      };

      mkInspectTree = doc: path: {
        inherit doc;
        silent = true;
        args = [
          "option"
          "cmd"
          "*args"
        ];
        dependencies = [ "(flake ${path} cmd args)" ];
      };

      mkDocsTree = doc: getOptions: {
        inherit doc;
        silent = true;
        args = [ "option" ];
        dependencies = [ "add" ];
        body = "nix build --file ${./_commands-option-doc.nix} --no-substitute --argstr flake \"{{ justfile_directory() }}\" --arg getOptions '${getOptions}' --argstr option \"{{ option }}\" --no-link --print-out-paths | xargs cat";
      };
    in
    {
      treefmt.programs.just.enable = true;

      files.justfile = {
        settings = [ "no-cd" ];

        inherit vars;

        order = [
          "default"
          "add"
          "generate"
          "os"
          "switch"
          "boot"
          "test"
          "fmt"
          "update-packages"
          "update"
        ];

        recipes = {
          default = {
            doc = "list the available recipes in all justfiles";
            silent = true;
            body = "just --list --list-submodules";
          };
          inherit add;
          generate = {
            doc = "regenerate the generated files";
            silent = true;
            dependencies = [ "add" ];
            body = "nix run .#generate-files";
          };
          os = {
            doc = "regenerate the files, then run `nh os` with the given action and flags";
            silent = true;
            args = [
              ''action="switch"''
              "*flags"
            ];
            dependencies = [ "generate" ];
            # `--no-nom` hides the nom progress bar when not on a TTY, and as a
            # subcommand flag it comes before the user's flags: `nh os <action> --no-nom ...`.
            body = "if [ -t 1 ]; then nh os {{ action }} {{ flags }}; else nh os {{ action }} --no-nom {{ flags }}; fi";
          };
          switch = {
            doc = "activate the configuration now, passing extra flags to `nh os`";
            silent = true;
            args = [ "*flags" ];
            dependencies = [ ''(os "switch" flags)'' ];
          };
          boot = {
            doc = "activate the configuration at the next boot, passing extra flags to `nh os`";
            silent = true;
            args = [ "*flags" ];
            dependencies = [ ''(os "boot" flags)'' ];
          };
          test = {
            doc = "activate the configuration without making it the boot default, passing extra flags to `nh os`";
            silent = true;
            args = [ "*flags" ];
            dependencies = [ ''(os "test" flags)'' ];
          };
          inherit fmt;
          update-packages = {
            doc = "run the update script of each package that has one";
            silent = true;
            args = [ "*packages" ];
            dependencies = [ "generate" ];
            body = "nix run .#update-packages -- {{ packages }}";
          };
          update = {
            doc = "update the flake inputs, then update each package";
            dependencies = [ "generate" ];
            body = ''
              nix flake update
              just update-packages
            '';
          };
        };

        modules = {
          eval = {
            inherit vars;
            order = [
              "add"
              "fmt"
              "nixos"
              "hm"
              "flake"
              "perSystem"
              "system"
            ];
            recipes = {
              add = mkPrivate add;
              fmt = mkPrivate fmt;
              nixos = mkEvalTree "evaluate a path under the current host's nixos config, e.g. `just eval nixos services.tailscale`" "{{ nixosConfig }}";
              hm = mkEvalTree "evaluate a home manager option, e.g. `just eval hm programs.git`" "{{ hmConfig }}";
              flake = mkEvalTree "evaluate a flake option's value, e.g. `just eval flake files.generatedMessage.text`" ".#debug.config";
              perSystem = mkEvalTree "evaluate a per-system option's value, e.g. `just eval perSystem files.readme.rendered`" "{{ perSystemConfig }}";
              system = {
                doc = "evaluate the whole configuration, and build nothing";
                silent = true;
                dependencies = [ "fmt" ];
                body = "nix eval --raw {{ systemPackage }}.drvPath";
              };
            };
          };

          build = {
            inherit vars;
            order = [
              "add"
              "flake"
              "nixos"
              "hm"
              "perSystem"
              "system"
            ];
            recipes = {
              add = mkPrivate add;
              flake = {
                doc = "build a flake path (or a nix build expression) and print its output store paths, without linking `result`";
                silent = true;
                args = [ "*args" ];
                dependencies = [ "add" ];
                body = "if [ -t 1 ]; then nom build --no-link --print-out-paths {{ args }}; else nix build --no-link --print-out-paths {{ args }}; fi";
              };
              nixos = mkBuildTree "build a nixos config path, e.g. `just build nixos system.build.toplevel`" "(nixosConfig + \".\" + option)";
              hm = mkBuildTree "build a home manager config path, e.g. `just build hm home.path`" "(hmConfig + \".\" + option)";
              perSystem = mkBuildTree "build a per-system config path, e.g. `just build perSystem packages.generate-files`" "(perSystemConfig + \".\" + option)";
              system = {
                doc = "build the whole configuration";
                silent = true;
                dependencies = [ "(flake systemPackage)" ];
              };
            };
          };

          inspect = {
            inherit vars;
            order = [
              "add"
              "flake"
              "nixos"
              "hm"
              "perSystem"
            ];
            recipes = {
              add = mkPrivate add;
              flake = {
                doc = "build a flake path and run a command in its output directory, e.g. `just inspect flake .#muvm-steam ls -la`";
                silent = true;
                args = [
                  "package"
                  "cmd"
                  "*args"
                ];
                dependencies = [ "add" ];
                body = "if [ -t 1 ]; then nom build --no-link --print-out-paths {{ package }} | while read -r out; do (cd \"$out\" && {{ cmd }} {{ args }}); done; else nix build --no-link --print-out-paths {{ package }} | while read -r out; do (cd \"$out\" && {{ cmd }} {{ args }}); done; fi";
              };
              nixos = mkInspectTree "build a nixos config path and run a command in its output directory, e.g. `just inspect nixos system.build.toplevel ls`" "(nixosConfig + \".\" + option)";
              hm = mkInspectTree "build a home manager config path and run a command in its output directory, e.g. `just inspect hm home.path ls`" "(hmConfig + \".\" + option)";
              perSystem = mkInspectTree "build a per-system config path and run a command in its output directory, e.g. `just inspect perSystem packages.generate-files ls`" "(perSystemConfig + \".\" + option)";
            };
          };

          docs = {
            inherit vars;
            order = [
              "add"
              "flake"
              "perSystem"
              "nixos"
              "hm"
            ];
            recipes = {
              add = mkPrivate add;
              flake = mkDocsTree "render a flake option's markdown docs, e.g. `just docs flake perSystem.files.readme`" "(flake: flake.debug.options)";
              perSystem = mkDocsTree "render a per-system option's markdown docs, e.g. `just docs perSystem files.commentedFile`" ''(flake: flake.allSystems."{{ system }}".options)'';
              nixos = mkDocsTree "render a nixos option's markdown docs, e.g. `just docs nixos services.tailscale`" ''(flake: flake.nixosConfigurations."{{ host }}".options)'';
              hm = mkDocsTree "render a home-manager option's markdown docs, e.g. `just docs hm programs.git`" ''(flake: flake.nixosConfigurations."{{ host }}".options.home-manager.users.type.getSubOptions ["home-manager" "users"])'';
            };
          };
        };
      };
    };
}
