{
  den.schema.flake-parts.includes = [
    {
      files.gitignore = ''
        result
        result-*
        result.*

        .direnv

        .pre-commit-config.yaml
      '';
    }
  ];
}
