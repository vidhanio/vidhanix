{
  flake-file.inputs.niri-scratchpad = {
    url = "github:argosnothing/niri-scratchpad-rs";
  };
  flake.aspects.niri = {
    nixos = {
      programs.niri.enable = true;
    };

    homeManager = { inputs', ... }: {
      home.packages = [ inputs'.niri-scratchpad.packages.default ];
      wayland.windowManager.niri.enable = true;
    };
  };
}
