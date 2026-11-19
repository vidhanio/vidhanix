{
  profiles.base = {
    module =
      { config, ... }:
      {
        programs.nushell.enable = true;
        users.defaultUserShell = config.programs.nushell.package;
      };
    homeModule =
      { pkgs, ... }:
      {
        programs = {
          nushell = {
            enable = true;

            settings = {
              show_banner = false;
              edit_mode = "vi";
            };

            extraLogin = "fastfetch";

            extraConfig = ''
              $env.PROMPT_INDICATOR = ""
              $env.PROMPT_INDICATOR_VI_INSERT = ""
              $env.PROMPT_INDICATOR_VI_NORMAL = ""
              $env.PROMPT_MULTILINE_INDICATOR = ""
              $env.PROMPT_COMMAND_RIGHT = {|| "" }

              $env.config.cursor_shape.vi_insert = "line"
              $env.config.cursor_shape.vi_normal = "block"
              $env.config.cursor_shape.vi_visual = "block"

              $env.PROMPT_COMMAND = {||
                  let exit_code = ($env.LAST_EXIT_CODE? | default 0)

                  let dir = (match (do -i { $env.PWD | path relative-to $nu.home-dir }) {
                      null => $env.PWD
                      "" => '~'
                      $relative => {
                          let parts = ($relative | path split)
                          let abbreviated = ($parts | drop | each {|part| $part | str substring 0..0 })
                          ([~ ...$abbreviated ($parts | last)] | path join)
                      }
                  })

                  let branch = (^git rev-parse --abbrev-ref HEAD | complete)
                  let branch = if $branch.exit_code == 0 { $branch.stdout | str trim } else { "" }
                  let vcs = if ($branch | is-empty) { "" } else { $" \(($branch)\)" }

                  let status = if $exit_code == 0 { "" } else { $"(ansi red)[($exit_code)](ansi reset)" }

                  let root = (($env.USER? | default "") == 'root')
                  let suffix = if $root { '#' } else { '>' }
                  let cwd = if $root { $"(ansi red)($dir)(ansi reset)" } else { $"(ansi green)($dir)(ansi reset)" }

                  $"($cwd)($vcs) ($status)($suffix) "
              }
            '';
          };

          carapace = {
            enable = true;
            enableNushellIntegration = true;
          };

        };

        # Nushell is the login shell; silence the pre-shell login banner.
        home.file.".hushlogin".source = pkgs.emptyFile;

        persist.files = [
          {
            file = ".config/nushell/history.txt";
            method = "symlink";
          }
        ];
      };
  };
}
