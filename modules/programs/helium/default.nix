{ inputs, ... }: {
  flake-file.inputs.helium-flake.url = "github:oxcl/nix-flake-helium-browser";

  flake.modules = {
    nixos.default = {
      imports = [ inputs.helium-flake.nixosModules.default ];
    };
    homeManager.default =
      { self', ... }:
      let
        pkg = self'.packages.helium-bin;
      in
      {
        imports = [ inputs.helium-flake.homeManager.default ];

        programs.helium.enable = true;

        xdg.autostart.entries = [ "${pkg}/share/applications/helium.desktop" ];

        hyprland.autostartWorkspaces.helium = 1;

        hyprland.binds."SUPER + B".exec_cmd = "uwsm app -- helium";

        persist.directories = [ ".config/net.imput.helium" ];
      };
  };
}
