{
  flake.aspects =
    { aspects, ... }:
    {
      vidhanio = {
        includes = [ aspects.desktop ];
        homeManager.programs.gh.username = "vidhanio";
      };
    };

  users.vidhanio = {
    fullName = "Vidhan Bhatt";
    email = "me@vidhan.io";
    publicKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINcNbwiEfw2GG4G//eWdtjyuv4S7vlkHuB9Z1INIfDwE vega"
    ];
    face = ./face.png;
  };
}
