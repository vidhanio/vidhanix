{
  flake.aspects.nixvim.homeManager = _: {
    programs.nixvim = {
      plugins.lspconfig.enable = true;
      plugins.schemastore.enable = true;

      lsp.servers = {
        # keep-sorted start
        bashls.enable = true;
        jsonls.enable = true;
        nil_ls.enable = true;
        nixd.enable = true;
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
    };
  };
}
