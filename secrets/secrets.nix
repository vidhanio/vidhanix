let
  keys = {
    vidhan-pc = {
      vidhanio = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDxMGko3NUtTtMB7pfDE1VYnTy1OR1fsLaGpVp9FaKtv vidhanio@vidhan-pc";
      root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPyMCXJxi0Ra1il/NUXl0Qf+zEv0sA53jXdvfqHpIKfB root@vidhan-pc";
    };
    vidhan-macbook = {
      vidhanio = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF/j/5jl9dCjEzecnWShJcku5pi0ZH2p5h6qPiRDpRkV vidhanio@vidhan-macbook";
    };
  };

  userKeys = user: map (users: users.${user}) (builtins.attrValues keys);

  users = userKeys "vidhanio";
  hosts = userKeys "root";
in
{

}
