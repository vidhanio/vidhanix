{
  inputs,
  config,
  ...
}:
{
  flake-file.inputs.nixvim.url = "github:nix-community/nixvim";

  den.default = {
    nixos = {
      imports = [ inputs.nixvim.nixosModules.default ];

      programs.nixvim.imports = [ config.flake.modules.nixvim.default ];
    };
    homeManager = {
      imports = [ inputs.nixvim.homeModules.default ];

      programs.nixvim.imports = [ config.flake.modules.nixvim.default ];
    };
    nixvim.default = {
      nixpkgs.useGlobalPackages = true;
    };
  };
}
