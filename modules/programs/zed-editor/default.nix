{
  flake.aspects.zed-editor = {
    homeManager = { pkgs, ... }: {
      programs.zed-editor = {
        enable = true;
        extensions = [ "nix" ];
        extraPackages = with pkgs; [
          nixd
          nil
          package-version-server
        ];
        userSettings = {
          format_on_save = "on";
          edit_predictions.allow_data_collection = "no";
          session.trust_all_worktrees = true;
          telemetry = {
            diagnostics = false;
            metrics = false;
            anthropic_retention = false;
          };

          agent_servers = {
            pi-acp.type = "registry";
            "Oh My Pi" = {
              type = "custom";
              command = "omp";
              args = [ "acp" ];
            };
            "Prime Agent" = {
              type = "custom";
              command = "prime-agent";
              args = [
                "--mode"
                "acp"
              ];
            };
            "OpenCode 2" = {
              type = "custom";
              command = "opencode2";
              args = [ "acp" ];
            };
          };

          vim_mode = true;

          vim = {
            use_system_clipboard = "always";
            use_smartcase_find = true;
            use_regex_search = true;
            gdefault = true;
            toggle_relative_line_numbers = true;
          };
        };

        mutableUserDebug = false;
        mutableUserKeymaps = false;
        mutableUserSettings = false;
        mutableUserTasks = false;
      };

      stylix.targets.zed.fonts.override = {
        sizes = {
          desktop = 8;
          terminal = 10;
        };
      };

      persist.directories = [ ".local/share/zed" ];
    };
  };
}
