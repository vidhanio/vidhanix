let
  keys = {
    vidhan-pc = {
      vidhanio = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDxMGko3NUtTtMB7pfDE1VYnTy1OR1fsLaGpVp9FaKtv vidhanio@vidhan-pc";
      root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICfS/WsqGHJYgJFWe+bf1SSKjyvFP0pISi30W/cvar/D root@vidhan-pc";
    };
    vidhan-macbook = {
      vidhanio = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKpEHUbyfwBLGJqsrZLO8xDpldmg655DPYLGNOJUJfHM vidhanio@vidhan-macbook";
      root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINrlsMqmLKW+8+MyHndMWNZXk86Oo0Ik8wPs3v1Nx7ZR root@vidhan-macbook";
    };
  };

  userKeys =
    user:
    map (users: users.${user}) (builtins.filter (users: users ? ${user}) (builtins.attrValues keys));

  users = userKeys "vidhanio";
  hosts = userKeys "root";
  all = users ++ hosts;
in
{
  "secrets/password.age".publicKeys = all;
  "secrets/wakatime.age".publicKeys = all;
  "secrets/networks.age".publicKeys = all;
}
