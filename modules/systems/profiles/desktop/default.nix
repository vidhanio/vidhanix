{
  flake.aspects =
    { aspects, ... }:
    {
      desktop.includes = with aspects; [
        gui

        # keep-sorted start
        boot._.desktop
        cachyos-kernel
        disk._.desktop
        herdr._.desktop
        # keep-sorted end
      ];
    };
}
