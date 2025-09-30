let
  keys = {
    vidhan-pc = {
      vidhanio = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDxMGko3NUtTtMB7pfDE1VYnTy1OR1fsLaGpVp9FaKtv vidhanio@vidhan-pc";
    };
    vidhan-macbook = {
      vidhanio = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKpEHUbyfwBLGJqsrZLO8xDpldmg655DPYLGNOJUJfHM vidhanio@vidhan-macbook";
    };
  };

  userKeys =
    user:
    map (users: users.${user}) (builtins.filter (users: users ? ${user}) (builtins.attrValues keys));

  users = userKeys "vidhanio";
in
{
  "users/vidhanio/wakatime.age".publicKeys = users;
}
