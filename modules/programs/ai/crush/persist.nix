{
  # Crush keeps global app data (settings overrides, workspace state) in
  # `$XDG_DATA_HOME/crush`, i.e. `~/.local/share/crush` on Linux/macOS
  # (internal/config/load.go: GlobalConfigData). Per-project data lives in
  # `<project>/.crush/` and is not touched here.
  flake.modules.homeManager.default = {
    persist.directories = [ ".local/share/crush" ];
  };
}
