let
  pkg =
    {
      lib,
      fetchFromGitHub,
      rustPlatform,
      vimUtils,
      nix-update-script,
    }:
    let
      version = "0.5.0-beta.1";

      src = fetchFromGitHub {
        owner = "sheng-tse";
        repo = "jupynvim";
        tag = "v${version}";
        hash = "sha256-Rn/qoIwp4CfYAIzRwKspemOyEEslYC3CUSGlebRaPx8=";
      };

      core = rustPlatform.buildRustPackage {
        pname = "jupynvim-core";
        inherit version src;

        cargoRoot = "core";
        buildAndTestSubdir = "core";
        cargoHash = "sha256-/hIY/JWart/5raM8wMCXtdcIlwX7y2iJoZRv3vZAvlg=";

        # These tests expect a root directory owned by the build user and an
        # unrestricted process environment, neither of which the sandbox provides.
        checkFlags = map (test: "--skip=${test}") [
          "connfile::tests::u3_prepare_root"
          "connfile::tests::u4_choose_root_falls_through_and_names_every_candidate"
          "connfile::tests::u12_exact_modes_under_a_umask_without_owner_bits"
          "connfile::tests::u16_backend_dir_made_again_when_removed"
          "connfile::tests::u18_an_exit_during_the_first_start_leaves_no_backend_dir"
          "connfile::tests::u20_waiting_removal_waits_for_the_backend_to_be_gone"
          "connfile::tests::u21_roots_only_below_dirs_nobody_else_can_change"
          "connfile::tests::u22_removal_never_follows_a_root_put_in_its_place"
          "connfile::tests::u23_sweep_and_guard_never_follow_a_root_replaced_by_a_symlink"
          "connfile::tests::u24_the_system_temp_dir_when_nothing_else_can_be_used"
          "connfile::tests::u27_no_remover_claims_a_dir_whose_removal_is_in_progress"
          "connfile::tests::u28_the_sweep_never_removes_the_old_location_used_as_a_root"
          "connfile::tests::u29_a_sweep_that_takes_the_dir_being_made_again_does_not_fail_the_start"
          "guard::tests::g2_serve_stops_a_registered_group_and_removes_the_dir"
          "guard::tests::g3_an_unregistered_group_keeps_running"
          "guard::tests::g4_a_held_lock_keeps_the_dir_and_the_group_is_still_stopped"
          "guard::tests::g8_a_lock_released_soon_after_the_end_of_input_is_waited_for"
          "kernel::tests::k15_other_processes_keep_no_inherited_fd"
        ];

        meta = {
          description = "Native backend for jupynvim";
          mainProgram = "jupynvim-core";
          homepage = "https://github.com/sheng-tse/jupynvim";
          license = lib.licenses.mit;
          platforms = lib.platforms.unix;
        };
      };
    in
    vimUtils.buildVimPlugin {
      pname = "jupynvim";
      inherit version src;

      postInstall = ''
        mkdir -p $out/bin
        install -m755 ${lib.getExe core} $out/bin/jupynvim-core
      '';

      passthru = {
        # Exposed so `nix-update` can refresh the core's vendored cargo hash.
        inherit (core) cargoDeps;

        updateScript = nix-update-script {
          extraArgs = [ "--version=unstable" ];
        };
      };

      meta = {
        description = "VSCode-style Jupyter notebook editing in Neovim";
        mainProgram = "jupynvim-core";
        homepage = "https://github.com/sheng-tse/jupynvim";
        changelog = "https://github.com/sheng-tse/jupynvim/releases/tag/v${version}";
        license = lib.licenses.mit;
        platforms = lib.platforms.unix;
      };
    };
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.jupynvim = pkgs.callPackage pkg { };
    };
}
