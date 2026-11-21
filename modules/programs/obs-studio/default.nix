{
  profiles.pc.homeModule =
    { pkgs, ... }:
    {
      programs.obs-studio = {
        enable = true;
        plugins = with pkgs.obs-studio-plugins; [
          obs-pipewire-audio-capture
          wlrobs
        ];
      };

      persist.directories = [ ".config/obs-studio" ];
    };
}
