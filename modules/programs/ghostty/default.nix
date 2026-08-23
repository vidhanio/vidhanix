{
  flake.aspects.ghostty = {
    homeManager = {
      programs.ghostty = {
        enable = true;
        settings =
          let
            padding = 8;
          in
          {
            window-padding-x = padding;
            window-padding-y = padding;
            background-opacity-cells = true;

            # stay resident with no windows open; new windows then take the fast path.
            quit-after-last-window-closed = false;
          };
      };
    };
  };
}
