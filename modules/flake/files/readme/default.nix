{
  perSystem.files.readme = {
    title = "❄️ vidhanix";
    order = [
      "introduction"
      "structure"
      "packages"
      "generated-files"
    ];
    content = {
      introduction = {
        title = "Introduction";
        content = ''
          A [Dendritic](https://github.com/mightyiam/dendritic) Nix flake for my stuff.
        '';
      };
      structure = {
        title = "Structure";
        content = ''
          Every automatically imported Nix file under `modules/` is a flake-parts module describing a feature.
          Features merge directly into the repository's own deferred-module options rather than registering per-app modules:

          - `profiles.<name>.module` and `profiles.<name>.homeModule` share NixOS and Home Manager configuration across machines.
            `base` is headless, `pc` inherits `base` for personal computers, and `apple-silicon` inherits `pc` for Apple hardware.
          - `hosts.<hostname>.{module,homeModule}` select profiles and add machine-specific configuration.
            Hosts also declare their platform, SSH key, and enabled users.
          - `users.<username>.module` holds per-user Home Manager configuration alongside identity, SSH keys, and an optional face image.

          Reusable lower-level modules live under `modules/upstream/_modules/{nixos,home-manager,stylix}` in upstream-style layouts.
          The underscore excludes them from automatic flake-parts importing.
          `nixosModules.upstream` and `homeModules.upstream` bundle them for the base profile and external consumers.
          Stylix targets use `<target>/{hm,nixos,meta}.nix` and the upstream `mkTarget` implementation, with a local autoloader matching Stylix's argument guards.
          Personal settings remain in the feature files outside `upstream`.
        '';
      };
      packages.title = "Packages";
      generated-files.title = "Generated Files";
    };
  };
}
