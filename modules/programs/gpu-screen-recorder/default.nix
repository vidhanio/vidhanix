{
  hosts.vortex.module = {
    programs.gpu-screen-recorder = {
      enable = true;
      ui.enable = true;
    };
  };
  hosts.vortex.homeModule.programs.gpu-screen-recorder-ui = {
    enable = true;
    package = null;
    mutableSettings = true;
  };
}
