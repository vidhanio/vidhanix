{
  profiles.pc.homeModule = _: {
    programs.nixvim = {
      plugins.lspconfig.enable = true;
      plugins.schemastore.enable = true;

      lsp.servers = {
        # keep-sorted start block=yes
        bashls.enable = true;
        codebook = {
          enable = true;
          config.filetypes.__raw = "vim.list_extend(vim.deepcopy(vim.lsp.config.codebook.filetypes), { 'nix' })";
        };
        jsonls.enable = true;
        lua_ls.enable = true;
        nil_ls.enable = true;
        nixd.enable = true;
        oxlint.enable = true;
        ruff.enable = true;
        rust_analyzer.enable = true;
        statix.enable = true;
        tailwindcss.enable = true;
        tinymist.enable = true;
        tombi.enable = true;
        tsc.enable = true;
        ty.enable = true;
        yamlls.enable = true;
        # keep-sorted end
      };

      diagnostic.settings.virtual_text = {
        prefix = "●";
        source = "if_many";
      };

      lsp.keymaps = [
        {
          key = "<leader>ca";
          lspBufAction = "code_action";
          mode = [
            "n"
            "v"
          ];
          options = {
            silent = true;
            desc = "Code action";
          };
        }
      ];
    };
  };
}
