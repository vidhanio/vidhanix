let
  pkg =
    {
      lib,
      fetchFromGitHub,
      python3Packages,
      nix-update-script,
    }:
    python3Packages.buildPythonPackage rec {
      pname = "conventional-pre-commit";
      version = "4.4.0";

      src = fetchFromGitHub {
        owner = "compilerla";
        repo = "conventional-pre-commit";
        tag = "v${version}";
        hash = "sha256-8wpsdrTv2N2FFMZzRzJ3ufFtTehoZTaiHvXxNbV6vIQ=";
      };

      pyproject = true;

      build-system = with python3Packages; [
        setuptools
      ];

      dependencies = with python3Packages; [
        setuptools-scm
      ];

      passthru.updateScript = nix-update-script {
        extraArgs = [ "--flake" ];
      };

      meta = {
        description = "A pre-commit hook that checks commit messages for Conventional Commits formatting";
        homepage = "https://github.com/compilerla/conventional-pre-commit";
        changelog = "https://github.com/compilerla/conventional-pre-commit/releases/tag/${src.tag}";
        license = lib.licenses.asl20;
        platforms = lib.platforms.all;
        mainProgram = "conventional-pre-commit";
      };
    };
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.conventional-pre-commit = pkgs.callPackage pkg { };
    };
}
