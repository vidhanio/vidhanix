{
  profiles.pc = {
    module = {
      programs.xtool.enable = true;
    };

    homeModule =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          swift
          swiftpm
        ];

        persist.directories = [
          ".config/swiftpm"
          ".config/xtool"
        ];
      };
  };
}
