{ lib, pkgs, ... }:
{
  flake.modules.homeManager.default = {
    home.activation.sshPubkey =
      let
        ssh-keygen = lib.getExe' pkgs.openssh "ssh-keygen";
      in
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p $HOME/.ssh
        run chmod 700 $HOME/.ssh
        if [ -f $HOME/.ssh/id_ed25519 ]; then
          run ${ssh-keygen} -y -f $HOME/.ssh/id_ed25519 > $HOME/.ssh/id_ed25519.pub
          run chmod 600 $HOME/.ssh/id_ed25519
          run chmod 644 $HOME/.ssh/id_ed25519.pub
        fi    
      '';
  };
}
