{
  flake.aspects.helix = {
    homeManager =
      { pkgs, ... }:
      {
        programs.helix = {
          enable = true;
          defaultEditor = true;
          settings.editor = {
            bufferline = "multiple";
            file-picker.hidden = false;
          };

          languages.language = [
            {
              name = "markdown";
              soft-wrap.enable = true;
            }
          ];

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
