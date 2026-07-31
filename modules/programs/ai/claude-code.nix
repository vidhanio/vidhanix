{ inputs, ... }: {
  flake.modules.homeManager.default = {
    programs.claude-code = {
      enable = true;
      skills = {
        karpathy-guidelines = "${inputs.andrej-karpathy-skills}/skills/karpathy-guidelines";
      };
      settings = {
        permissions.defaultMode = "auto";
        attribution = {
          commit = "";
          pr = "";
          sessionUrl = false;
        };
      };
    };

    persist = {
      directories = [ ".claude" ];
      files = [ ".claude.json" ];
    };
  };
}
