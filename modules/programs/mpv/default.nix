{
  profiles.pc = {
    homeModule =
      { pkgs, ... }:
      {
        programs.mpv = {
          enable = true;
          scripts = [ pkgs.mpvScripts.mpris ];
          config = {
            hwdec = "auto-safe";
            vo = "gpu-next";
            keep-open = true;
            save-position-on-quit = true;
          };
        };
      };
  };
}
