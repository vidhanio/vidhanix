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

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence/home-manager-v2";

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # vidhanix-fonts.url = "git+ssh://git@github.com/vidhanio/vidhanix-fonts";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      determinate,
      darwin,
      home-manager,
      agenix,
      ...
    }:
    let
      lib = nixpkgs.lib.extend (
        _: _: with builtins; {
          readDirToList = path: map (name: path + "/${name}") (attrNames (readDir path));
          importSubmodules =
            path:
            map (name: path + "/${name}") (filter (name: name != "default.nix") (attrNames (readDir path)));
        }
      );

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      isLinux = system: (lib.systems.elaborate system).isLinux;
      isDarwin = system: (lib.systems.elaborate system).isDarwin;

      linuxSystems = builtins.filter isLinux systems;
      darwinSystems = builtins.filter isDarwin systems;

      forEachSystem =
        systems: f:
        lib.genAttrs systems (
          system:
          f {
            inherit system;
            pkgs = (
              import nixpkgs {
                inherit system;

                overlays = lib.optional (isDarwin system) (darwin.overlays.default);
              }
            );
          }
        );

      mkConfigurations =
        { kind, mkSystem }:
        hosts:
        lib.genAttrs hosts (
          host:
          mkSystem {
            modules = [
              { networking.hostName = host; }
              ./hosts/common.nix
              ./hosts/${kind}/common.nix
              ./hosts/${kind}/${host}
            ];
            inherit lib;
            specialArgs = { inherit inputs; };
          }
        );

      mkScriptApp =
        pkgs:
        {
          name,
          runtimeInputs,
          text,
        }:
        {
          type = "app";
          program = lib.getExe (
            pkgs.writeShellApplication {
              inherit name runtimeInputs text;
            }
          );
        };
    in
    {
      nixosConfigurations = mkConfigurations {
        kind = "nixos";
        mkSystem = nixpkgs.lib.nixosSystem;
      } [ "vidhan-pc" ];

      darwinConfigurations = mkConfigurations {
        kind = "darwin";
        mkSystem = darwin.lib.darwinSystem;
      } [ "vidhan-macbook" ];

      devShells = forEachSystem systems (
        { pkgs, ... }:
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              direnv

              git

              nixfmt
              nil

              shfmt
              shellcheck
            ];
          };
        }
      );

      apps =
        let
          linuxPackages = forEachSystem linuxSystems (
            { pkgs, ... }:
            {
              default = mkScriptApp pkgs {
                name = "rebuild";
                runtimeInputs = with pkgs; [ nixos-rebuild-ng ];
                text = ''
                  nixos-rebuild --sudo --flake ${self} "''${@:-switch}"
                '';
              };
            }
          );
          darwinPackages = forEachSystem darwinSystems (
            { pkgs, ... }:
            {
              default = mkScriptApp pkgs {
                name = "rebuild";
                runtimeInputs = with pkgs; [ darwin-rebuild ];
                text = ''
                  sudo darwin-rebuild --flake ${self} "''${@:-switch}"
                '';
              };
            }
          );
        in
        linuxPackages // darwinPackages;

      formatter = forEachSystem systems ({ pkgs, ... }: pkgs.nixfmt-tree);
    };
}
