{
  profiles.pc.homeModule = {
    programs.nixvim.plugins = {
      blink-cmp = {
        enable = true;
        settings = {
          cmdline.enabled = false;
          keymap.preset = "super-tab";
        };
      };
    };
  };
}
