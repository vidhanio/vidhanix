{
  users.vidhanio = {
    fullName = "Vidhan Bhatt";
    email = "me@vidhan.io";
    module = {
      programs.gh.username = "vidhanio";
    };
  };
  flake.modules.nixos.default = {
    users.users.vidhanio.enable = true;
  };
}
