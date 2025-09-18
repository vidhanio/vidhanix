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
    vidhanix-fonts.url = "git+ssh://git@github.com/vidhanio/vidhanix-fonts";
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
        _: _:
        with builtins;
        let
          readDirContents' =
            cond: path: map (name: path + "/${name}") (filter cond (attrNames (readDir path)));
        in
        {
          readDirContents = readDirContents' (lib.const true);
          readSubmodules = readDirContents' (name: name != "default.nix");
        }
      );

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      isDarwin = system: (lib.systems.elaborate system).isDarwin;

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
        { system, pkgs }:
        let
          rebuild =
            let
              cmd = if (isDarwin system) then "sudo darwin-rebuild" else "nixos-rebuild --sudo";
            in
            pkgs.writeShellApplication {
              name = "rebuild";
              text = ''
                ${cmd} --flake . "''${@:-switch}"
              '';
            };
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              direnv

              git

              nixfmt
              nil

              shfmt
              shellcheck

              rebuild
            ];
          };
        }
      );

      formatter = forEachSystem systems ({ pkgs, ... }: pkgs.nixfmt-tree);
    };
}
