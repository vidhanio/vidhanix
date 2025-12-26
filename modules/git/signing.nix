{
  flake.modules.homeManager.default = {
    programs.git = {
      signing = {
        format = "ssh";
        signByDefault = true;
      };
      settings.user.signingkey = "~/.ssh/id_ed25519.pub";
    };
  };
}
