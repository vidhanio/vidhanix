{
  profiles.pc = {
    homeModule =
      { pkgs, ... }:
      {
        programs.zathura = {
          enable = true;
          package = pkgs.zathura.override {
            plugins = [ pkgs.zathuraPkgs.zathura_pdf_mupdf ];
          };
        };
      };
  };
}
