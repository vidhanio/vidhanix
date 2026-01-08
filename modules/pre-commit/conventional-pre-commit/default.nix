{
  perSystem =
    { self', ... }:
    {
      pre-commit.settings.hooks.conventional-pre-commit = {
        enable = true;
        package = self'.packages.conventional-pre-commit;
        entry = "conventional-pre-commit";
        always_run = true;
        description = "Checks commit message for Conventional Commits formatting";
        stages = [ "commit-msg" ];
      };
    };
}
