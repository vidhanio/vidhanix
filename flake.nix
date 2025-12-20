# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://nixos-apple-silicon.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
    ];
    extra-trusted-substituters = [
      "https://nix-community.cachix.org"
      "https://nixos-apple-silicon.cachix.org"
    ];
  };

  inputs = {
    agenix.url = "github:ryantm/agenix";
    cannonball = {
      flake = false;
      url = "github:libretro/cannonball";
    };
    determinate.url = "github:DeterminateSystems/determinate";
    dinothawr = {
      flake = false;
      url = "github:libretro/dinothawr";
    };
    dirksimple = {
      flake = false;
      url = "github:icculus/DirkSimple";
    };
    disko.url = "github:nix-community/disko";
    ecwolf = {
      flake = false;
      url = "github:libretro/ecwolf";
    };
    flake-file.url = "github:vic/flake-file";
    flake-parts = {
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
      url = "github:hercules-ci/flake-parts";
    };
    fonts = {
      flake = false;
      url = "git+ssh://git@github.com/vidhanio/fonts";
    };
    ghostty-shader-playground = {
      flake = false;
      url = "github:KroneCorylus/ghostty-shader-playground";
    };
    home-manager.url = "github:nix-community/home-manager";
    impermanence.url = "github:vidhanio/impermanence/hmv2-trash";
    import-tree.url = "github:vic/import-tree";
    libretro-database-src = {
      flake = false;
      url = "github:libretro/libretro-database";
    };
    libretro-super = {
      flake = false;
      url = "github:libretro/libretro-super";
    };
    libretro-system-files-src = {
      flake = false;
      url = "github:libretro/libretro-system-files";
    };
    nixcord.url = "github:FlameFlag/nixcord";
    nixos-apple-silicon.url = "github:nix-community/nixos-apple-silicon";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-lib.follows = "nixpkgs";
    qemu-libretro = {
      flake = false;
      url = "github:io12/qemu-libretro";
    };
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    stylix.url = "github:nix-community/stylix";
    systems.url = "github:nix-systems/default-linux";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    xrick-libretro = {
      flake = false;
      url = "github:libretro/xrick-libretro";
    };
  };

}
