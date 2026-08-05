{
  flake.modules.nixvim.default = {
    enable = true;
    defaultEditor = true;
    viAlias = true;

    clipboard = {
      register = "unnamedplus";
      providers.wl-copy.enable = true;
    };

    # These groups come from the colorscheme with their own background.
    # Clear just the background, keeping each group's foreground, so they
    # blend into the code background instead of showing a different shade.
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
      # mini.basics' own default value plus "popup", for inline LSP doc
      # preview in the completion menu. Set explicitly here (rather than
      # letting mini.basics set its default) since it loads first and
      # mini.basics only sets an option if it isn't already set.
      completeopt = "menuone,noselect,popup";
    };
  };
}
