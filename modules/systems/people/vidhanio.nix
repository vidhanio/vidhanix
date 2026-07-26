{ den, ... }:
{
  people.vidhanio = {
    fullName = "Vidhan Bhatt";
    email = "me@vidhan.io";
    extraPublicKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINcNbwiEfw2GG4G//eWdtjyuv4S7vlkHuB9Z1INIfDwE vidhanio@vidhan-iphone"
    ];
  };

  den.aspects.vidhanio = {
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
    ];

    homeManager = {
      programs.gh.username = "vidhanio";
    };
  };
}
