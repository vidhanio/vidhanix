{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    determinate = {
      url = "github:DeterminateSystems/determinate";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    systems.url = "github:nix-systems/default";

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence/home-manager-v2";

    determinate-nix = {
      url = "github:DeterminateSystems/nix-src";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vidhanix-fonts = {
      url = "git+ssh://git@github.com/vidhanio/vidhanix-fonts";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord = {
      url = "github:kaylorben/nixcord";
    };

    vesktop = {
      url = "github:Vencord/Vesktop";
      flake = false;
    };
    ghostty-shader-playground = {
      url = "github:KroneCorylus/ghostty-shader-playground";
      flake = false;
    };
  };

  outputs =
    {
      self,
      agenix,
      darwin,
      determinate,
      determinate-nix,
      disko,
      firefox-addons,
      home-manager,
      impermanence,
      nixpkgs,
      stylix,
      systems,
      vidhanix-fonts,
      nixcord,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib.extend (final: prev: import ./lib prev);

      nixpkgsCfg = {
        config.allowUnfree = true;
        overlays = [
          determinate-nix.overlays.default
          vidhanix-fonts.overlays.default
          firefox-addons.overlays.default
          agenix.overlays.default
          (final: prev: {
            lib = prev.lib.extend (final: prev: import ./lib prev);
          })
        ]
        ++ map import (lib.readDirContents ./overlays);
      };

      forEachSystem =
        f:
        lib.genAttrs (import systems) (
          system:
          f {
            inherit system;
            pkgs = import nixpkgs (nixpkgsCfg // { system = system; });
          }
        );

      mkConfigurations =
        {
          class,
          mkSystem,
          extras ? [ ],
        }:
        hosts:
        let
          moduleInputs = [
            determinate
            home-manager
            stylix
            agenix
            impermanence
            disko
          ];

          modules = map (input: input."${class}Modules".default) (
            builtins.filter (input: input ? "${class}Modules") moduleInputs
          );

          homeModules = [
            # impermanence.homeManagerModules.default <- added conditionally in modules/shared/impermanence.nix
            agenix.homeManagerModules.default
            nixcord.homeModules.default
          ];
        in
        lib.genAttrs hosts (
          host:
          mkSystem {
            specialArgs = { inherit inputs; };
            inherit lib;

            modules = [
              ./hosts/${host}
            ]
            ++ modules
            ++ lib.readDirContents ./modules/shared
            ++ lib.readDirContents ./modules/${class}
            ++ [
              { nixpkgs = nixpkgsCfg; }
              { networking.hostName = host; }
              (
                { config, ... }:
                {
                  home-manager = {
                    users =
                      let
                        isNormalUser = user: (user.isNormalUser or true) && !(lib.hasPrefix "_" user.name);
                      in
                      lib.genAttrs' (builtins.filter isNormalUser (builtins.attrValues config.users.users)) (
                        user: lib.nameValuePair user.name ./users/${user.name}
                      );
                    sharedModules = homeModules ++ lib.readSubmodules ./modules/home;
                    useGlobalPkgs = true;
                    extraSpecialArgs = { inherit inputs; };
                  };
                }
              )
            ];
          }
        );

      mkNixosConfigurations = mkConfigurations {
        class = "nixos";
        mkSystem = nixpkgs.lib.nixosSystem;
        extras = [
          impermanence
          disko
        ];
      };
      mkDarwinConfigurations = mkConfigurations {
        class = "darwin";
        mkSystem = darwin.lib.darwinSystem;
      };

      isDarwin = system: builtins.elem system lib.platforms.darwin;
    in
    {
      lib = import ./lib nixpkgs.lib;

      nixosConfigurations = mkNixosConfigurations [ "vidhan-pc" ];
      darwinConfigurations = mkDarwinConfigurations [ "vidhan-macbook" ];

      devShells = forEachSystem (
        { system, pkgs }:
        let
          rebuild = pkgs.writeShellApplication {
            name = "rebuild";
            text =
              let
                cmd = if (isDarwin system) then "sudo darwin-rebuild" else "nixos-rebuild --sudo";
              in
              ''
                git add .
                ${cmd} --flake . "''${@:-switch}"
                if ! git diff --cached --quiet; then
                  git commit -m "chore: rebuild system"
                fi
              '';
          };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              nixfmt-rfc-style
              nil

              pkgs.agenix

              rebuild
            ];
          };
        }
      );

      formatter = forEachSystem (
        { pkgs, ... }: pkgs.nixfmt-tree.override { nixfmtPackage = pkgs.nixfmt-rfc-style; }
      );
    };
}
