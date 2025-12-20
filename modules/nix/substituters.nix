{
  flake-file.nixConfig =
    let
      substituters = [
        "https://nix-community.cachix.org"
        "https://nixos-apple-silicon.cachix.org"
      ];
    in
    {
      extra-substituters = substituters;
      extra-trusted-substituters = substituters;

      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
      ];
    };
}
