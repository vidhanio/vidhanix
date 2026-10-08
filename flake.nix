{
  nixConfig = {
    allow-import-from-derivation = false;
    extra-experimental-features = [
      "nix-command"
      "flakes"
    ];
    extra-substituters = [
      "https://install.determinate.systems"
      "https://hyprland.cachix.org"
      "https://cache.numtide.com"
      "https://attic.xuyh0120.win/lantian"
      "https://nix-community.cachix.org"
      "https://vidhanio.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "vidhanio.cachix.org-1:Qzk2G10fmck+K+pxP5nvHC5yl/ic315by091/bJpnio="
    ];
  };

  inputs = {
    # core
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    import-tree = {
      url = "github:denful/import-tree";
    };
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    systems = {
      url = "github:nix-systems/default-linux";
    };

    # tooling
    files = {
      url = "github:mightyiam/files";
      flake = false;
    };
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # system
    determinate = {
      url = "github:DeterminateSystems/determinate";
      inputs.nix.inputs = {
        flake-parts.follows = "flake-parts";
        git-hooks-nix.follows = "git-hooks-nix";
      };
    };
    disko = {
      url = "github:vidhanio/disko/feature/skip-partition-uuid";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
    };
    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
      inputs.flake-parts.follows = "flake-parts";
    };
    nixos-apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # desktop
    cursor-shaders = {
      url = "github:sahaj-b/cursor-shaders";
      flake = false;
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs = {
        aquamarine.inputs.nixpkgs.follows = "nixpkgs";
        hyprcursor.inputs.nixpkgs.follows = "nixpkgs";
        hyprgraphics.inputs.nixpkgs.follows = "nixpkgs";
        hyprland-guiutils.inputs.nixpkgs.follows = "nixpkgs";
        hyprland-protocols.inputs.nixpkgs.follows = "nixpkgs";
        hyprlang.inputs.nixpkgs.follows = "nixpkgs";
        hyprtoolkit.inputs.nixpkgs.follows = "nixpkgs";
        hyprutils.inputs.nixpkgs.follows = "nixpkgs";
        hyprwayland-scanner.inputs.nixpkgs.follows = "nixpkgs";
        hyprwire.inputs.nixpkgs.follows = "nixpkgs";
        pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        xdph.inputs.nixpkgs.follows = "nixpkgs";
      };
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        tinted-schemes.follows = "tinted-schemes";
      };
    };
    tinted-schemes = {
      url = "github:tinted-theming/schemes";
      flake = false;
    };
    vidhan-fonts = {
      url = "git+ssh://git@github.com/vidhanio/fonts";
      flake = false;
    };

    # programs
    helium = {
      url = "github:schembriaiden/helium-browser-nix-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.inputs.systems.follows = "systems";
      };
    };
    mcsr = {
      url = "https://git.uku3lig.net/uku/mcsr-nixos/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord = {
      url = "github:4evy/nixcord";
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };
    spotifast = {
      url = "github:crmne/spotifast";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # agents
    agentcord = {
      url = "github:vidhanio/agentcord";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs = {
        flake-parts.follows = "flake-parts";
        systems.follows = "systems";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
