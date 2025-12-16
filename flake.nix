{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # no `follows` to avoid invalidating cache
    determinate.url = "github:DeterminateSystems/determinate";
    determinate-nix.url = "github:DeterminateSystems/nix-src";
    apple-silicon.url = "github:nix-community/nixos-apple-silicon";

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
    impermanence = {
      # https://github.com/nix-community/impermanence/pull/272
      # https://github.com/nix-community/impermanence/pull/243
      url = "github:vidhanio/impermanence/hmv2-trash";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-extensions = {
      url = "github:dseum/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fonts = {
      url = "git+ssh://git@github.com/vidhanio/fonts";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib.extend (import ./lib);

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      nixpkgsCfg = {
        config.allowUnfree = true;
        overlays =
          with inputs;
          [
            # determinate-nix.overlays.default
            firefox-addons.overlays.default
            agenix.overlays.default
            vscode-extensions.overlays.default
          ]
          ++ lib.attrValues self.overlays;
      };

      forEachSystem =
        f:
        lib.genAttrs systems (
          system:
          f {
            inherit system;
            pkgs = import nixpkgs (nixpkgsCfg // { system = system; });
          }
        );

      mkNixOSConfigurations =
        hosts:
        let
          nixosModules =
            with inputs;
            map (input: input.nixosModules.default) [
              determinate
              home-manager
              stylix
              agenix
              impermanence
              disko
              spicetify-nix
            ];

          homeModules =
            with inputs;
            map (input: (input.homeModules or input.homeManagerModules).default) [
              impermanence
              agenix
              spicetify-nix
            ];
        in
        lib.genAttrs hosts (
          host:
          nixpkgs.lib.nixosSystem {
            inherit lib;
            specialArgs = { inherit inputs; };

            modules = [
              ./hosts/${host}
              { networking.hostName = host; }
            ]
            ++ nixosModules
            ++ lib.readDirContents ./modules
            ++ [
              (
                {
                  lib,
                  config,
                  inputs,
                  ...
                }:
                {
                  nixpkgs = nixpkgsCfg;
                  nix.registry =
                    let
                      flakes = lib.filterAttrs (_: input: input ? _type && input._type == "flake") inputs;
                    in
                    lib.mapAttrs (_: flake: { inherit flake; }) flakes;

                  home-manager = {
                    users =
                      let
                        users = lib.filter (user: user.isNormalUser) (lib.attrValues config.users.users);
                      in
                      lib.genAttrs' users (user: lib.nameValuePair user.name ./users/${user.name});
                    sharedModules = homeModules;
                    extraSpecialArgs = { inherit inputs; };
                  };
                }
              )
            ];
          }
        );
    in
    {
      inherit inputs;
      nixosConfigurations = mkNixOSConfigurations [
        "vidhan-pc"
        "vidhan-macbook"
      ];

      overlays = lib.importDirAttrs ./overlays // {
        fonts = final: prev: { inherit (inputs) fonts; };
      };

      packages = forEachSystem (
        { pkgs, ... }:
        pkgs.lib.packagesFromDirectoryRecursive {
          inherit (pkgs) callPackage;
          directory = ./packages;
        }
        // {
          vidhanix-github-matrix = pkgs.writeText "matrix.json" (
            let
              mkMatrixElements =
                let
                  mkMatrixElement = name: host: {
                    inherit name;
                    inherit (host) class;
                    inherit (host.config.nixpkgs.hostPlatform) system;
                  };
                in
                hosts: lib.attrValues (lib.mapAttrs mkMatrixElement hosts);
            in
            pkgs.lib.strings.toJSON {
              include = (mkMatrixElements self.nixosConfigurations);
            }
          );
        }
      );

      devShells = forEachSystem (
        { system, pkgs }:
        let
          update = pkgs.writeShellApplication {
            name = "update";

            runtimeInputs = with pkgs; [
              nix
              nix-update
              jq
            ];

            text = ''
              nix flake update

              packages=$(
                nix eval --json .#packages."${system}" --apply 'builtins.mapAttrs (_: pkg: pkg ? passthru.updateScript)' |
                  jq -r 'with_entries(select(.value)) | keys | .[]'
              )

              for package in $packages; do
                nix-update --flake -u --build "$package"
              done
            '';
          };

          rebuild = pkgs.writeShellApplication {
            name = "rebuild";

            runtimeInputs = with pkgs; [
              git
              nh
              direnv
            ];

            text = ''
              git add .

              nh os "''${@:-switch}"

              direnv reload
            '';
          };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              git
              direnv

              nixfmt-rfc-style
              nil

              shellcheck
              shfmt

              agenix

              update
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
