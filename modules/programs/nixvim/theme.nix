_: {
  flake.aspects.nixvim.homeManager = {
    # Same :highlight calls stylix's own neovim target makes for its transparent
    # backgrounds. nixvim's highlightOverride can't be used here: it replaces
    # the group wholesale and drops the sign colours with the background.
    programs.nixvim.extraConfigLuaPost = ''
      -- mini.base16 points the diagnostic signs at their floating-window
      -- variants, which carry a background; nvim's own default targets don't.
      for _, severity in ipairs({ "Error", "Warn", "Info", "Hint", "Ok" }) do
        vim.cmd.highlight({ "link", "DiagnosticSign" .. severity, "Diagnostic" .. severity })
      end

      for _, name in ipairs({
        "SignColumn",
        "LineNr",
        "LineNrAbove",
        "LineNrBelow",
        "MiniDiffSignAdd",
        "MiniDiffSignChange",
        "MiniDiffSignDelete",
      }) do
        vim.cmd.highlight({ name, "guibg=NONE", "ctermbg=NONE" })
      end
    '';
  };
}
