{
  flake.modules.homeManager.default = _: {
    home.shellAliases.h = "herdr";

    programs.herdr = {
      enable = true;

      # TODO: restore the llm-agents herdr package once its source hash is valid.
      # llm-agents pins herdr v0.8.0 from github:ogulcancelik/herdr, which moved
      # to herdrdev/herdr; the tag tarball's fetchzip hash no longer matches the
      # pinned one, so the hm build fails with a hash mismatch. The default
      # package (nixpkgs) builds fine.
      # package = inputs'.llm-agents.packages.herdr;

      settings = {
        onboarding = false;

        ui.tab_bar_position = "bottom";
        ui.show_agent_labels_on_pane_borders = true;
        ui.toast.delivery = "system";

        experimental.kitty_graphics = true;

        experimental.pane_history = true;

        keys.command = [
          {
            key = "prefix+alt+g";
            type = "popup";
            command = "lazygit";
            width = "80%";
            height = "80%";
            description = "lazygit";
          }
        ];
      };
    };

    programs.agents.skills.skills.herdr = ./SKILL.md;

    persist.files =
      map
        (file: {
          inherit file;
          method = "symlink";
        })
        [
          ".config/herdr/session.json"
          ".config/herdr/session-history.json"
        ];
  };
}
