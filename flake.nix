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
      mkConfigurations =
        { kind, lib }:
        let
          lib-utils =
            _: _: with builtins; {
              readDirToList = path: map (name: path + "/${name}") (attrNames (readDir path));
              readCurrentDir =
                path:
                map (name: path + "/${name}") (filter (name: name != "default.nix") (attrNames (readDir path)));
            };
        in
        hosts:
        lib.genAttrs hosts (
          host:
          (lib.extend lib-utils)."${kind}System" {
            modules = [
              { networking.hostName = host; }
              ./hosts/common.nix
              ./hosts/${kind}/common.nix
              ./hosts/${kind}/${host}
            ];
            specialArgs = { inherit inputs; };
          }
        );

      mkNixosConfigurations = mkConfigurations {
        kind = "nixos";
        lib = nixpkgs.lib;
      };

      mkDarwinConfigurations = mkConfigurations {
        kind = "darwin";
        lib = darwin.lib;
      };
    in
    {
      nixosConfigurations = mkNixosConfigurations [ "vidhan-pc" ];
    };
}
