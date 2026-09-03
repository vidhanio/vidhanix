{
  flake.aspects.helix = {
    homeManager =
      { pkgs, ... }:
      {
        programs.helix = {
          enable = true;
          defaultEditor = true;

          extraPackages = with pkgs; [
            nil
            nixd
            ruff
            rust-analyzer
            ty
          ];
        };
      };
  };
}
