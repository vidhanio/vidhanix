let
  keys = {
    vidhan-pc = {
      vidhanio = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDxMGko3NUtTtMB7pfDE1VYnTy1OR1fsLaGpVp9FaKtv vidhanio@vidhan-pc";
      root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPyMCXJxi0Ra1il/NUXl0Qf+zEv0sA53jXdvfqHpIKfB root@vidhan-pc";
    };
    vidhan-macbook = {
      vidhanio = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKpEHUbyfwBLGJqsrZLO8xDpldmg655DPYLGNOJUJfHM vidhanio@vidhan-macbook";
    };
  };

  userKeys =
    user:
    map (users: users.${user}) (builtins.filter (users: users ? ${user}) (builtins.attrValues keys));

  users = userKeys "vidhanio";
  hosts = userKeys "root";
in
{
  "wakatime.age".publicKeys = users;
}
