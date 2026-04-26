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
          extensions = [
            # 1Password Nightly
            # {
            #   id = "gejiddohjgogedgjnonbofjigllpkmbf";
            #   hash = "sha256-47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=";
            # }

            # Violentmonkey
            {
              id = "jinjaccalgkegednnccohejagnlnfdag";
              hash = "sha256-OOnRfEig1MO3RuQnGQx2Hr1v3/8XhNN6qUMGdSKc2Ug=";
            }

            # Refined GitHub
            # {
            #   id = "hlepfoohegkhhmjieoechaddaejaokhf";
            #   hash = "sha256-47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=";
            # }

            # SteamDB
            {
              id = "kdbmhfkmnlmbkgbabkdealhhbfhlmmon";
              hash = "sha256-9DoDSDFI5SjYJDRNMwOol02Wh4Xa2WhZYTLR+fim+Zk=";
            }
          ];
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
