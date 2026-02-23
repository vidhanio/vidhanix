{
  inputs,
  config,
  ...
}:
{
  flake-file.inputs.nixvim.url = "github:nix-community/nixvim";

  flake.modules = {
    nixos.default = {
      imports = [ inputs.nixvim.nixosModules.default ];

      programs.nixvim.imports = [ config.flake.modules.nixvim.default ];
    };
    homeManager.default = {
      imports = [ inputs.nixvim.homeModules.default ];

      programs.nixvim.imports = [ config.flake.modules.nixvim.default ];
    };
  };
}
