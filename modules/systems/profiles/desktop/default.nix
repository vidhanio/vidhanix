{
  flake.aspects =
    { aspects, ... }:
    {
      desktop.includes = with aspects; [
        gui

        # keep-sorted start
        boot.provides.desktop
        cachyos-kernel
        disk.provides.desktop
        # keep-sorted end
      ];
    };
}
