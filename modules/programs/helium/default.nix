{ inputs, withSystem, ... }:
{
  flake-file.inputs.helium.url = "gitlab:ntgn/helium-flake";

  flake.modules = {
    nixos.default = {
      imports = [ inputs.helium.nixosModules.helium ];
    };
    homeManager.default =
      { pkgs, config, ... }:
      {
        imports = [ inputs.helium.homeModules.helium ];

        programs.helium = {
          enable = true;
          defaultBrowser = true;
          package = withSystem pkgs.stdenv.hostPlatform.system ({ self', ... }: self'.packages.helium-bin);
        };

        xdg.autostart.entries = [ "${config.programs.helium.package}/share/applications/helium.desktop" ];

        hyprland.autostartWorkspaces.helium = 1;

        wayland.windowManager.hyprland.settings.bind = [
          "SUPER, B, exec, uwsm app -- helium"
        ];

        persist.directories = [ ".config/net.imput.helium" ];
      };
  };
}
