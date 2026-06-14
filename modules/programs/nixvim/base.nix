{
  flake.modules.nixvim.default = {
    enable = true;
    defaultEditor = true;
    viAlias = true;

    clipboard = {
      register = "unnamedplus";
      providers.wl-copy.enable = true;
    };

    globals.mapleader = " ";

    opts = {
      number = true;
      signcolumn = "yes";
      scrolloff = 8;
      wrap = false;
      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
      undofile = true;
      splitright = true;
      splitbelow = true;
      foldlevelstart = 99;
    };
  };
}
