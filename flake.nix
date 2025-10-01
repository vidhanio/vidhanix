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
    vidhanix-fonts.url = "git+ssh://git@github.com/vidhanio/vidhanix-fonts";
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
      vidhanix-fonts,
      ...
    }:
    let
      lib-overlay =
        final: prev:
        let
          readDirContents' =
            with builtins;
            cond: path: map (name: path + "/${name}") (filter cond (attrNames (readDir path)));
        in
        {
          readDirContents = readDirContents' (_: true);
          readSubmodules = readDirContents' (name: name != "default.nix");

          getDesktop' = pkg: name: "${pkg}/share/applications/${name}.desktop";
          getDesktop = pkg: final.getDesktop' pkg (prev.getName pkg);
        };

      lib = nixpkgs.lib.extend lib-overlay;

      nixpkgsConfig = {
        config.allowUnfree = true;
        overlays = [
          determinate-nix.overlays.default
          vidhanix-fonts.overlays.default
          firefox-addons.overlays.default
          agenix.overlays.default
          (final: prev: {
            lib = prev.lib.extend lib-overlay;
          })
        ]
        ++ map import (lib.readDirContents ./overlays);
      };

      forAllSystems =
        f:
        lib.genAttrs lib.systems.flakeExposed (
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
      inherit lib;

      nixosConfigurations = mkConfigurations {
        mkSystem = nixpkgs.lib.nixosSystem;
        modules = [
          determinate.nixosModules.default
          home-manager.nixosModules.default
          stylix.nixosModules.stylix
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
          stylix.darwinModules.stylix
          agenix.nixosModules.default
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
              direnv

              git

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
    };
}
