{ inputs, ... }:
{
  # TODO: switch back to github:hgaiser/moonshine once
  # https://github.com/hgaiser/moonshine/pull/141 is merged.
  flake-file.inputs.moonshine.url = "github:scottjab/moonshine/scottjab/fix-polkit-extra-policies";

  flake.modules = {
    nixos.default =
      { config, ... }:
      {
        imports = [ inputs.moonshine.nixosModules.default ];

        services.moonshine = {
          enable = true;
          user = config.users.primaryUser;
          # uid is not derivable: users are declared without a fixed uid, so
          # NixOS allocates it dynamically. Hardcoded to match the primary
          # user's actual allocated uid (verified with `id -u`).
          uid = 1000;
          openFirewall = true;
        };
      };
    homeManager.default = {
      persist.directories = [
        ".config/moonshine"
        ".local/share/moonshine"
      ];
    };
  };
}
