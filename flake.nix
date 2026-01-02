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
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
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
    nixcord = {
      url = "github:FlameFlag/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fonts = {
      url = "git+ssh://git@github.com/vidhanio/fonts";
      flake = false;
    };

    import-tree.url = "github:vic/import-tree";

    ghostty-shader-playground = {
      url = "github:KroneCorylus/ghostty-shader-playground";
      flake = false;
    };
    libretro-super = {
      url = "github:libretro/libretro-super";
      flake = false;
    };
    libretro-database-src = {
      url = "github:libretro/libretro-database";
      flake = false;
    };
    libretro-system-files-src = {
      url = "github:libretro/libretro-system-files";
      flake = false;
    };

    cannonball = {
      url = "github:libretro/cannonball";
      flake = false;
    };
    dinothawr = {
      url = "github:libretro/dinothawr";
      flake = false;
    };
    dirksimple = {
      url = "github:icculus/DirkSimple";
      flake = false;
    };
    ecwolf = {
      url = "github:libretro/ecwolf";
      flake = false;
    };
    qemu-libretro = {
      url = "github:io12/qemu-libretro";
      flake = false;
    };
    xrick-libretro = {
      url = "github:libretro/xrick-libretro";
      flake = false;
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
