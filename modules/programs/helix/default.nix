{
  flake.aspects.helix = {
    homeManager =
      { pkgs, ... }:
      {
        programs.helix = {
          enable = true;
          defaultEditor = true;
          settings.editor.cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };

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
