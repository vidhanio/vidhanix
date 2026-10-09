{
  profiles.pc.homeModule =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      openTypstPreview = pkgs.writeShellApplication {
        name = "open-typst-preview";
        runtimeInputs = [
          config.programs.herdr.package
          pkgs.coreutils
          pkgs.jq
          pkgs.xdg-utils
        ];
        text = ''
          if [[ "''${HERDR_ENV:-}" == 1 ]]; then
            profile=$(mktemp -d)
            pane=$(herdr pane split --current --direction right --cwd "$PWD" --no-focus | jq -er '.result.pane.pane_id')
            printf -v command '%q ' \
              ${lib.getExe config.programs.meowland.package} run \
              ${lib.getExe config.programs.helium.package} \
              "--user-data-dir=$profile" "--app=$1"
            herdr pane run "$pane" "$command"
          else
            xdg-open "$1"
          fi
        '';
      };
    in
    {
      programs.nixvim.plugins = {
        direnv.enable = true;
        image.enable = true;
        typst-preview = {
          enable = true;
          settings = {
            invert_colors = "auto";
            open_cmd = "${lib.getExe openTypstPreview} %s";
          };
        };
        wakatime.enable = true;
      };
    };
}
