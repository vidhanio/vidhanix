{
  flake.modules.nixos.apple-silicon = {
    extra-substituters = [
      "https://nixos-apple-silicon.cachix.org"
    ];

    extra-trusted-public-keys = [
      "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
    ];
  };
}
