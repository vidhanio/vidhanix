{
  flake.aspects.helix = {
    homeManager =
      { pkgs, ... }:
      {
        programs.helix = {
          enable = true;
          defaultEditor = true;
          settings.editor.bufferline = "multiple";

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
