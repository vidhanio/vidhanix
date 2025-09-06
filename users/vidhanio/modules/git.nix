{ osConfig, ... }:
{
  programs.git = {
    userName = osConfig.me.fullname;
    userEmail = "me@vidhan.io";
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
