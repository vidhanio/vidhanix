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
        title = "Overview";
        content = ''
          Personal NixOS and Home Manager configurations for x86-64 and Apple Silicon machines.
          Built with flake-parts and import-tree using the [Dendritic pattern](https://github.com/mightyiam/dendritic).
        '';
      };
      structure = {
        title = "Structure";
        content = ''
          ```text
          modules/
            profiles/   # shared configuration and hardware profiles
            hosts/      # machine metadata and host-specific configuration
            users/      # identities and per-user Home Manager configuration
            system/     # boot, storage, persistence, and Nix
            desktop/    # shared bindings, workspaces, appearance, and session helpers
            programs/   # applications, compositors, adapters, and packages
            services/   # service configuration
            upstream/   # reusable NixOS, Home Manager, and Stylix modules
            flake/      # inputs, tooling, generated files, and infrastructure
          ```

          import-tree discovers feature modules under `modules/`. Features contribute to deferred modules through three option groups:

          - `profiles.<name>.{module,homeModule}`: shared NixOS and Home Manager configuration.
            `base` provides headless foundations, `pc` adds desktop configuration, and `apple-silicon` extends `pc` for Apple hardware.
          - `hosts.<hostname>.{module,homeModule}`: profile selection and machine-specific configuration, accompanied by platform, SSH key, and user metadata.
          - `users.<username>.module`: per-user Home Manager configuration, accompanied by identity and SSH keys.

          Reusable modules live in `modules/upstream/_modules/{nixos,home-manager,stylix}/`.
          The base profile imports the exported `nixosModules.upstream` and `homeModules.upstream` bundles.
          Keep related settings, packages, and assets beside their owning feature.
        '';
      };
      packages.title = "Packages";
      generated-files.title = "Generated Files";
    };
  };
}
