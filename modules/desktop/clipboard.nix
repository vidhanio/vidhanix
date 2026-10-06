{
  profiles.pc = {
    homeModule =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          wl-clipboard
        ];

        services.cliphist.enable = true;
      };
  };
}
