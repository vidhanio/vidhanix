{
  flake.aspects.nixvim.homeManager = _: {
    programs.nixvim = {
      plugins.lspconfig.enable = true;
      plugins.schemastore.enable = true;

      lsp.servers = {
        # keep-sorted start
        jsonls.enable = true;
        nil_ls.enable = true;
        ruff.enable = true;
        rust_analyzer.enable = true;
        statix.enable = true;
        tailwindcss.enable = true;
        tinymist.enable = true;
        tombi.enable = true;
        ty.enable = true;
        yamlls.enable = true;
        # keep-sorted end
      };

      diagnostic.settings = {
        virtual_text.prefix = "";
        signs.numhl.__raw = ''
          {
            [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
            [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
            [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
            [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
          }
        '';
      };

    };
  };
}
