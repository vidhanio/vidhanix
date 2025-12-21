{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # no `follows` to avoid invalidating cache
    determinate.url = "github:DeterminateSystems/determinate";
    nixos-apple-silicon.url = "github:nix-community/nixos-apple-silicon";

    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";

    stylix = {
      url = "github:nix-community/stylix";
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

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:nix-community/nur-combined?dir=repos/rycee/pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
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

    import-tree.url = "github:vic/import-tree";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      import-tree,
      ...
    }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      {
        withSystem,
        lib,
        ...
      }:
      let
        nixosModules =
          with inputs;
          map (input: input.nixosModules.default) [
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
      in {};

        perSystem =
          {
            system,
            pkgs,
            ...
          }:
          let
            inherit (pkgs) lib;
          in
          {
            _module.args.pkgs = import nixpkgs {
              inherit system;
              overlays =
                with inputs;
                map (input: input.overlays.default) [
                  firefox-addons
                  agenix
                  vscode-extensions
                ]
                ++ lib.attrValues self.overlays;
              config.allowUnfree = true;
            };

            packages =
              lib.packagesFromDirectoryRecursive {
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
                    include = mkMatrixElements self.nixosConfigurations;
                  }
                );
              };
          };
      }
    );
}
