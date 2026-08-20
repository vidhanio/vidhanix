{
  flake-file.inputs.helium.url = "github:schembriaiden/helium-browser-nix-flake";

  flake.aspects.helium = {
    homeManager =
      { inputs', ... }:
      let
        pkg = inputs'.helium.packages.default;
      in
      {
        home.packages = [ pkg ];

        xdg.autostart.entries = [ "${pkg}/share/applications/helium.desktop" ];

        hyprland.autostartWorkspaces.helium = 1;

        hyprland.binds."SUPER + B".exec_cmd = "uwsm app -- helium";

        persist.directories = [ ".config/net.imput.helium" ];
      };
  };
}
