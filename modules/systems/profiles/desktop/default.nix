{
  flake.aspects =
    { aspects, ... }:
    {
      desktop.includes = with aspects; [
        gui

        # keep-sorted start
        cachyos-kernel
        disk.provides.desktop
        disk.provides.impermanence.provides.tmpfs
        herdr.provides.vortex
        # keep-sorted end
      ];
    };
}
