{
  den.default.homeManager =
    { pkgs, ... }:
    {
      home.file.".hushlogin".source = pkgs.emptyFile;
    };
}
