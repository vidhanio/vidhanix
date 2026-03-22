_: {
  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      programs.opencode = {
        enable = true;
        enableMcpIntegration = true;
        package = pkgs.opencode;
      };

      persist.directories = [
        ".local/state/opencode"
        ".local/share/opencode"
      ];
    };
}
