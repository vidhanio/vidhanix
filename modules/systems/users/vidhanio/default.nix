{ withSystem, inputs, ... }:
let
  face = withSystem "x86_64-linux" (
    { pkgs, ... }:
    pkgs.fetchurl {
      url = "https://github.com/vidhanio.png";
      hash = "sha256-EKG8tBhhWgIiuBsYYoVPObzSdb9tZS+mqwon72h+AD8=";
    }
  );
in
{
  flake.aspects =
    { aspects, ... }:
    {
      vidhanio = {
        includes = [
          aspects.desktop
          aspects.herdr
        ];
        homeManager = {
          home.file.".face".source = face;
          programs.gh.username = "vidhanio";
          persist = {
            directories = [ ".herdr/worktrees" ];
            files = [
              {
                file = ".config/herdr/session.json";
                method = "symlink";
              }
            ];
          };
        };
      };
    };

  users.vidhanio = {
    fullName = "Vidhan Bhatt";
    email = "me@vidhan.io";
    publicKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINcNbwiEfw2GG4G//eWdtjyuv4S7vlkHuB9Z1INIfDwE vidhanio@vidhan-iphone"
    ];
    inherit face;
    module = inputs.self.modules.homeManager.vidhanio;
  };
}
