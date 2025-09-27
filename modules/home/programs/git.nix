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
      assertion = cfg.userEmail != null;
      message = "programs.git.userEmail must be set";
    }
  ];

  programs.git = {
    userName = lib.mkDefault osConfig.users.users.${config.home.username}.description;
    signing = {
      format = "ssh";
      signByDefault = true;
    };
    extraConfig = {
      init.defaultBranch = "main";
      submodule.recurse = true;
      push.autoSetupRemote = true;
      user.signingkey = "~/.ssh/id_ed25519.pub";
    };
    lfs.enable = true;
  };
}
