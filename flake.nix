{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
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
          readCurrentDir =
            path:
            map (name: path + "/${name}") (filter (name: name != "default.nix") (attrNames (readDir path)));
        }
      );

      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      linuxSystems = with builtins; filter (system: match ".*-linux$" system != null) systems;
      darwinSystems = with builtins; filter (system: match ".*-darwin$" system != null) systems;

      forEachSystem = lib.genAttrs;

      mkConfigurations =
        kind: mkSystem: hosts:
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

      devShells = forEachSystem systems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              git
              nixfmt-rfc-style
              nil
            ];
          };
        }
      );

      packages =
        let
          linuxPackages = forEachSystem linuxSystems (
            system:
            let
              pkgs = import nixpkgs { inherit system; };
            in
            {
              default = pkgs.writeShellApplication {
                name = "nixos-rebuild";

                runtimeInputs = [ pkgs.nixos-rebuild ];

                text = ''
                  nixos-rebuild "''${@:-switch}" --sudo --flake ${self}
                '';
              };
            }
          );
          darwinPackages = forEachSystem darwinSystems (
            system:
            let
              pkgs = import nixpkgs {
                inherit system;
                overlays = [ darwin.overlays.default ];
              };
            in
            {
              default = pkgs.writeShellApplication {
                name = "darwin-rebuild";

                runtimeInputs = [ pkgs.darwin-rebuild ];

                text = ''
                  sudo darwin-rebuild "''${@:-switch}" --flake ${self}
                '';
              };
            }
          );
        in
        linuxPackages // darwinPackages;
    in
    {
      nixosConfigurations = mkConfigurations "nixos" nixpkgs.lib.nixosSystem [ "vidhan-pc" ];
      darwinConfigurations = mkConfigurations "darwin" darwin.lib.darwinSystem [ "vidhan-macbook" ];

      inherit devShells packages;
    };
}
