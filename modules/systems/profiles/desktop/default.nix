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
        # keep-sorted end
      ];
    };
}
