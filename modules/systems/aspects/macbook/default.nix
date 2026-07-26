{
  inputs,
  ...
}:
{
  flake-file = {
    inputs.nixos-apple-silicon.url = "github:nix-community/nixos-apple-silicon";
    nixConfig = {
      extra-substituters = [ "https://nixos-apple-silicon.cachix.org" ];
      extra-trusted-public-keys = [
        "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
      ];
    };
    prune-lock.ignore = [ "nixos-apple-silicon" ];
  };

  den.aspects.macbook.nixos = {
    imports = [ inputs.nixos-apple-silicon.nixosModules.default ];
  };
}
