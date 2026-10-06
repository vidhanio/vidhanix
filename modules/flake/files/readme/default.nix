{
  perSystem.files.readme = {
    title = "❄️ vidhanix";
    order = [
      "introduction"
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
      packages.title = "Packages";
      generated-files.title = "Generated Files";
    };
  };
}
