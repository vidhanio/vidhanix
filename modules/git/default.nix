{
  config,
  ...
}:
{
  flake.modules.homeManager.default = args: {
    programs.git = {
      settings = {
        user =
          let
            inherit (args.config.home) username;
          in
          {
            name = config.users.${username}.fullName;
            email = config.users.${username}.email;
          };

        init.defaultBranch = "main";

        push.autoSetupRemote = true;
        pull.rebase = true;
        rebase.autostash = true;
        merge.ff = "only";
        submodule.recurse = true;

        url."git@github.com:".insteadOf = "https://github.com/";
      };
      lfs.enable = true;
    };
  };
}
