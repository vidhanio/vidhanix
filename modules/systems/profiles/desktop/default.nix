{
  flake.aspects =
    { aspects, ... }:
    {
      desktop.includes = with aspects; [
        gui
        cachyos-kernel
        disk.provides.desktop
        boot.provides.desktop
      ];
    };
}
