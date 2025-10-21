{
  lib,
  osConfig,
  config,
  ...
}:
let
  cfg = config.programs.git;
in
{
  assertions = lib.mkIf cfg.enable [
    {
      assertion = cfg.settings.user.email != null;
      message = "programs.git.settings.user.email must be set";
    }
  ];

  programs.git = {
    signing = {
      format = "ssh";
      signByDefault = true;
    };
    settings = {
      user.name = lib.mkDefault osConfig.users.users.${config.home.username}.description;

      init.defaultBranch = "main";
      user.signingkey = "~/.ssh/id_ed25519.pub";

      push.autoSetupRemote = true;
      pull.rebase = true;
      merge.ff = "only";
      submodule.recurse = true;

      url."git@github.com:".insteadOf = "https://github.com/";
    };
    lfs.enable = true;
  };
}
