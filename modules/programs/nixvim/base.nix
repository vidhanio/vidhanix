{
  flake.aspects.nixvim = {
    nixvim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;

      clipboard = {
        register = "unnamedplus";
        providers.wl-copy.enable = true;
      };

      # Colorscheme groups ship their own bg; clear it so they blend into the code background.
      # Wrap long lines in prose, breaking at word boundaries.
      autoCmd = [
        {
          event = [ "FileType" ];
          pattern = [ "markdown" ];
          command = "setlocal wrap linebreak";
        }
      ];

      extraConfigLuaPost = ''
        for _, name in ipairs({
          "SignColumn",
          "LineNr",
          "MiniDiffSignAdd",
          "MiniDiffSignChange",
          "MiniDiffSignDelete",
          "DiagnosticSignError",
          "DiagnosticSignWarn",
          "DiagnosticSignInfo",
          "DiagnosticSignHint",
        }) do
          local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
          hl.bg = nil
          vim.api.nvim_set_hl(0, name, hl)
        end
      '';

      opts = {
        scrolloff = 8;
        expandtab = true;
        shiftwidth = 2;
        tabstop = 2;
        foldlevelstart = 99;
        winborder = "rounded";
        # mini.basics' default plus "popup" for inline LSP docs; set first, since
        # mini.basics skips options that are already set.
        completeopt = "menuone,noselect,popup";
      };
    };
  };
}
