{
  inputs,
  config,
  ...
}:
{

  # pinned to the commit before linux-asahi 7.1.5, which breaks muvm's DRM
  # native context: https://github.com/AsahiLinux/muvm/issues/240
  flake-file.inputs.nixos-apple-silicon.url = "github:nix-community/nixos-apple-silicon/3902c801519264191a7c3dfec8dd1f9faeb38fd5";

  flake.modules.nixos.macbook = {
    imports = [
      config.flake.modules.nixos.default
      inputs.nixos-apple-silicon.nixosModules.default
    ];

    hardware.asahi.enable = true;
  };
}
