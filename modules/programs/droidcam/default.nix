{
  profiles.pc = {
    module = {
      programs.droidcam.enable = true;
      boot.extraModprobeConfig = ''
        options v4l2loopback exclusive_caps=1 card_label=DroidCam
      '';
    };

    homeModule.persist.files = [ ".config/droidcam" ];
  };
}
