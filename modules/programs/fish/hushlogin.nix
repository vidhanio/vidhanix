{
  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      home.file.".hushlogin".source = pkgs.emptyFile;
    };
}
