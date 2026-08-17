{
  inputs,
  ...
}:
{
  flake-file.inputs.nixvim.url = "github:nix-community/nixvim";

  flake.aspects.nixvim = {
    nixos = {
      imports = [ inputs.nixvim.nixosModules.default ];
      programs.nixvim.imports = [ inputs.self.modules.nixvim.nixvim ];
    };
    homeManager = {
      imports = [ inputs.nixvim.homeModules.default ];
      programs.nixvim.imports = [ inputs.self.modules.nixvim.nixvim ];
    };
    nixvim.nixpkgs.useGlobalPackages = true;
  };
}
