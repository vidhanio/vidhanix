{
  profiles.pc.homeModule =
    { config, ... }:
    let
      inherit (config.lib.stylix.colors.withHashtag)
        base01
        base02
        base03
        base05
        base08
        base0A
        base0B
        base0E
        ;
    in
    {
      programs.nixvim.highlightOverride = {
        # base16 swaps fg/bg for selection; lighten the background instead.
        PmenuSel = {
          fg = base05;
          bg = base02;
        };
        PmenuMatchSel = {
          fg = base05;
          bg = base02;
          bold = true;
        };
        MiniTablineModifiedCurrent = {
          fg = base0A;
          bg = base02;
          bold = true;
        };
        MiniTablineModifiedHidden = {
          fg = base0A;
          bg = base01;
        };
        MiniTablineModifiedVisible = {
          fg = base0A;
          bg = base01;
          bold = true;
        };

        # Hide the mini.pick footer (source name and match counts).
        MiniPickBorderText = {
          fg = base01;
          bg = base01;
        };

        # Transparent sign columns.
        SignColumn = {
          fg = base03;
          bg = "NONE";
        };
        LineNr = {
          fg = base03;
          bg = "NONE";
        };
        LineNrAbove = {
          fg = base03;
          bg = "NONE";
        };
        LineNrBelow = {
          fg = base03;
          bg = "NONE";
        };
        MiniDiffSignAdd = {
          fg = base0B;
          bg = "NONE";
        };
        MiniDiffSignChange = {
          fg = base0E;
          bg = "NONE";
        };
        MiniDiffSignDelete = {
          fg = base08;
          bg = "NONE";
        };

        # mini.base16 points the diagnostic signs at their floating-window
        # variants, which carry a background; nvim's own defaults don't.
        DiagnosticSignError = {
          link = "DiagnosticError";
        };
        DiagnosticSignWarn = {
          link = "DiagnosticWarn";
        };
        DiagnosticSignInfo = {
          link = "DiagnosticInfo";
        };
        DiagnosticSignHint = {
          link = "DiagnosticHint";
        };
        DiagnosticSignOk = {
          link = "DiagnosticOk";
        };
      };
    };
}
