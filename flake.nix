{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
    impermanence.url = "github:nix-community/impermanence";

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
      nixpkgs,
      determinate,
      darwin,
      home-manager,
      agenix,
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
          modules = map (module: ./modules/${module}) (builtins.attrNames (builtins.readDir ./modules));
        in
        lib.genAttrs hosts (
          host:
          mkSystem {
            specialArgs = { inherit inputs; };
            modules = modules ++ [
              determinate
              home-manager
              { me.host = host; }
              ./hosts/common.nix
              agenix.nixosModules.default
              ./hosts/${directory}/${host}
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
