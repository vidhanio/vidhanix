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
    vidhanix-fonts = {
      url = "git+ssh://git@github.com/vidhanio/vidhanix-fonts";
      inputs.nixpkgs.follows = "nixpkgs";
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
      nixpkgs,
      darwin,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib.extend (final: prev: import ./lib prev);

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      nixpkgsCfg = {
        config.allowUnfree = true;
        overlays =
          with inputs;
          [
            determinate-nix.overlays.default
            vidhanix-fonts.overlays.default
            firefox-addons.overlays.default
            agenix.overlays.default
          ]
          ++ builtins.attrValues self.overlays;
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
          ];

          osModules = map (input: input."${class}Modules".default) (
            builtins.filter (input: input ? "${class}Modules") moduleInputs
          );

          homeModules = with inputs; [
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
              { networking.hostName = host; }
            ]
            ++ osModules
            ++ lib.readDirContents ./modules/shared
            ++ lib.readDirContents ./modules/${class}
            ++ [
              { nixpkgs = nixpkgsCfg; }
              (
                { config, ... }:
                {
                  home-manager = {
                    users =
                      let
                        normalUsers =
                          let
                            users = builtins.attrValues config.users.users;
                            isNormalUser = user: (user.isNormalUser or true) && !(lib.hasPrefix "_" user.name);
                          in
                          builtins.filter isNormalUser users;
                      in
                      lib.genAttrs' normalUsers (user: lib.nameValuePair user.name ./users/${user.name});
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
        extras = with inputs; [
          impermanence
          disko
        ];
      };
      mkDarwinConfigurations = mkConfigurations {
        class = "darwin";
        mkSystem = darwin.lib.darwinSystem;
      };
    in
    {
      lib = import ./lib nixpkgs.lib;

      nixosConfigurations = mkNixosConfigurations [ "vidhan-pc" ];
      darwinConfigurations = mkDarwinConfigurations [ "vidhan-macbook" ];

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
                hosts: builtins.attrValues (builtins.mapAttrs mkMatrixElement hosts);
            in
            builtins.toJSON {
              include =
                (mkMatrixElements self.nixosConfigurations) ++ (mkMatrixElements self.darwinConfigurations);
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
            ];

            text = ''
              # add all changes to git
              git add .

              # run command
              # we will use `nix eval --json .#nixosConfigurations/darwinConfigurations --apply builtins.attrNames` | jq to find whether this uname -n is a darwin or nixos system
              is_class() {
                local class=$1
                nix eval --json .#"$class"Configurations --apply builtins.attrNames | jq --arg hostname "$(uname -n)" -e 'any(. == $hostname)'
              }

              if is_class darwin; then
                nh darwin "''${@:-switch}"
              elif is_class nixos; then
                nh os "''${@:-switch}"
              else
                echo "unknown host: $(uname -n)"
                exit 1
              fi
            '';
          };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              nixfmt-rfc-style
              nil

              shellcheck
              shfmt

              pkgs.agenix

              nix-update

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
