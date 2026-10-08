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
        # The `base16` module swaps `fg`/`bg` for selection; lighten the background instead.
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

        MiniPickBorderText = {
          fg = base01;
          bg = base01;
        };

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
