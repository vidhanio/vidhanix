{
  profiles.base = {
    homeModule =
      { inputs', ... }:
      {
        home.packages = [ inputs'.iets.packages.default ];
      };
  };
}
