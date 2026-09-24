{
  flake-file.inputs.niri-scratchpad = {
    url = "github:gvolpe/niri-scratchpad";
  };
  flake.aspects.niri = {
    nixos = {
      programs.niri.enable = true;
    };

    homeManager = { inputs', ... }: {
      home.packages = [ inputs'.niri-scratchpad.packages.niri-scratchpad ];
      wayland.windowManager.niri.enable = true;
    };
  };
}
