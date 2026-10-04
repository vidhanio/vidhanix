{
  flake.aspects =
    { aspects, ... }:
    {
      workstation.includes = with aspects; [
        gui

        # keep-sorted start
        cachyos-kernel
        disk.provides.impermanence.provides.tmpfs
        disk.provides.workstation
        # keep-sorted end
      ];
    };
}
