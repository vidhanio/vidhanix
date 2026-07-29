{ withSystem, ... }:
{
  users.vidhanio = {
    fullName = "Vidhan Bhatt";
    email = "me@vidhan.io";
    publicKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINcNbwiEfw2GG4G//eWdtjyuv4S7vlkHuB9Z1INIfDwE vidhanio@vidhan-iphone"
    ];
    face = withSystem "x86_64-linux" (
      { pkgs, ... }:
      pkgs.fetchurl {
        url = "https://github.com/vidhanio.png";
        hash = "sha256-EKG8tBhhWgIiuBsYYoVPObzSdb9tZS+mqwon72h+AD8=";
      }
    );
    module = {
      programs.gh.username = "vidhanio";
    };
  };
}
