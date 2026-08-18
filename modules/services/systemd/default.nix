{
  flake.aspects.systemd = {
    nixos = {
      persist.directories = [ "/var/lib/systemd/timers" ];
    };
  };
}
