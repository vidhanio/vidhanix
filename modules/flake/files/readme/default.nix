{
  den.schema.flake-parts.includes = [
    {
      files.readme = {
        title = "❄️ vidhanix";
        order = [
          "introduction"
          "packages"
          "generated-files"
        ];
        content.introduction.content = ''
          a [dendritic](https://github.com/mightyiam/dendritic) nix flake for my stuff.
        '';
      };
    }
  ];
}
