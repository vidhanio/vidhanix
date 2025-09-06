{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    determinate = {
      url = "github:DeterminateSystems/determinate";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      darwin,
      home-manager,
      determinate,
      ...
    }:
    let
      inherit (nixpkgs) lib;

      mkConfigurations =
        {
          directory,
          mkSystem,
          determinate,
          home-manager,
        }:
        let
          hosts = builtins.attrNames (builtins.readDir ./hosts/${directory});
        in
        lib.genAttrs hosts (
          host:
          mkSystem {
            specialArgs = { inherit inputs; };
            modules = [
              determinate
              home-manager
              { me.host = host; }
              ./modules/me.nix
              ./hosts/common.nix
              ./hosts/${directory}/${host}
              ./hosts/${directory}/${host}/hardware-configuration.nix
            ];
          }
        );
    in
    {
      nixosConfigurations = mkConfigurations {
        directory = "nixos";
        mkSystem = nixpkgs.lib.nixosSystem;
        determinate = determinate.nixosModules.default;
        home-manager = home-manager.nixosModules.default;
      };

      darwinConfigurations = mkConfigurations {
        directory = "darwin";
        mkSystem = darwin.lib.darwinSystem;
        determinate = determinate.darwinModules.default;
        home-manager = home-manager.darwinModules.default;
      };
    };
}
