{
  users.vidhanio = {
    fullName = "Vidhan Bhatt";
    email = "me@vidhan.io";
    module =
      { pkgs, ... }:
      {
        programs.gh.username = "vidhanio";
        home.file.".face".source = pkgs.fetchurl {
          url = "https://github.com/vidhanio.png";
          hash = "sha256-ApFyRcwZJ6V7wBNpQwYwGzzw+R17bZe1NGV0ikOzjOo=";
        };
      };
  };
  flake.modules.nixos.default = {
    users.users.vidhanio.enable = true;
  };
}
