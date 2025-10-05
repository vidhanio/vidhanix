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

    ghostty-shader-playground = {
      url = "github:KroneCorylus/ghostty-shader-playground";
      flake = false;
    };
  };

  outputs =
    inputs@{
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
      ...
    }:
    let
      lib = nixpkgs.lib.extend (final: prev: import ./lib prev);

      nixpkgsConfig = {
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

      forAllSystems =
        f:
        lib.genAttrs (import systems) (
          system:
          f {
            inherit system;
            pkgs = import nixpkgs (nixpkgsConfig // { system = system; });
          }
        );

      mkConfigurations =
        {
          mkSystem,
          modules,
        }:
        hosts:
        lib.genAttrs hosts (
          host:
          mkSystem {
            modules =
              modules
              ++ (lib.readDirContents ./modules)
              ++ [
                {
                  networking.hostName = host;
                  nixpkgs = nixpkgsConfig;
                }
                ./hosts/shared.nix
                ./hosts/${host}
              ];
            specialArgs = { inherit inputs; };
            inherit lib;
          }
        );

      isDarwin = system: builtins.elem system lib.platforms.darwin;
    in
    {
      lib = import ./lib nixpkgs.lib;

      nixosConfigurations = mkConfigurations {
        mkSystem = nixpkgs.lib.nixosSystem;
        modules = [
          determinate.nixosModules.default
          home-manager.nixosModules.default
          stylix.nixosModules.default
          agenix.nixosModules.default
          impermanence.nixosModules.default
          disko.nixosModules.default
        ];
      } [ "vidhan-pc" ];

      darwinConfigurations = mkConfigurations {
        mkSystem = darwin.lib.darwinSystem;
        modules = [
          determinate.darwinModules.default
          home-manager.darwinModules.default
          stylix.darwinModules.default
          agenix.darwinModules.default
        ];
      } [ "vidhan-macbook" ];

      devShells = forAllSystems (
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
            buildInputs = with pkgs; [
              nixfmt-rfc-style
              nil

              pkgs.agenix

              rebuild
            ];
          };
        }
      );

      formatter = forAllSystems (
        { pkgs, ... }: pkgs.nixfmt-tree.override { nixfmtPackage = pkgs.nixfmt-rfc-style; }
      );

      packages = forAllSystems ({ pkgs, ... }: pkgs);
    };
}
