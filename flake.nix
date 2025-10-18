{
  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org/"
      "https://install.determinate.systems"
      "https://nix-community.cachix.org/"
      "https://nixos-apple-silicon.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
    ];
  };

  inputs = {
    # self.submodules = true;

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
      # https://github.com/ryantm/agenix/pull/350
      url = "github:vidhanio/agenix/pkgs-getconf";
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

    determinate-nix = {
      url = "github:DeterminateSystems/nix-src";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
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
            determinate-nix.overlays.default
            firefox-addons.overlays.default
            agenix.overlays.default
            apple-silicon.overlays.default
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

      mkConfigurations =
        {
          class,
          mkSystem,
          extras ? [ ],
        }:
        hosts:
        let
          moduleInputs = with inputs; [
            determinate
            home-manager
            stylix
            agenix
            impermanence
            disko
            apple-silicon
          ];

          osModules = map (input: input."${class}Modules".default) (
            lib.filter (input: input ? "${class}Modules") moduleInputs
          );

          homeModules = with inputs; [
            impermanence.homeManagerModules.default
            agenix.homeManagerModules.default
          ];
        in
        lib.genAttrs hosts (
          host:
          mkSystem {
            inherit lib;

            modules = [
              ./hosts/${host}
              { networking.hostName = host; }
            ]
            ++ osModules
            ++ lib.readDirContents ./modules
            ++ [
              (
                { lib, config, ... }:
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
                        allUsers = lib.attrValues config.users.users;
                        isNormalUser = user: (user.isNormalUser or true) && !(lib.hasPrefix "_" user.name);
                        users = lib.filter isNormalUser allUsers;
                      in
                      lib.genAttrs' users (user: lib.nameValuePair user.name ./users/${user.name});
                    sharedModules = homeModules;
                  };
                }
              )
            ];
          }
        );

      mkNixosConfigurations = mkConfigurations {
        class = "nixos";
        mkSystem = nixpkgs.lib.nixosSystem;
        extras = with inputs; [
          impermanence
          disko
        ];
      };
    in
    {
      nixosConfigurations = mkNixosConfigurations [
        "vidhan-pc"
        "vidhan-macbook"
      ];

      overlays = lib.importDirAttrs ./overlays;

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
<<<<<<< HEAD
              include = (mkMatrixElements self.nixosConfigurations);
=======
              include =
                (mkMatrixElements self.nixosConfigurations);
>>>>>>> a7c4ac7 (macbook)
            }
          );
        }
      );

      devShells = forEachSystem (
        { system, pkgs }:
        let
          rebuild = pkgs.writeShellApplication {
            name = "rebuild";

            runtimeInputs = with pkgs; [
              git
              nix
              nh
              jq
              direnv
            ];

            text = ''
              # add all changes to git
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

              pkgs.agenix

              update-package

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
