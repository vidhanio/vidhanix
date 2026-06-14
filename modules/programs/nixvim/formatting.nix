{
  flake.modules.nixvim.default.plugins = {
    conform-nvim = {
      enable = true;
      settings = {
        formatters_by_ft."*" = [ "treefmt" ];
        formatters.treefmt.require_cwd = false;
        format_on_save = {
          timeout_ms = 500;
          lsp_fallback = true;
        };
      };
    };
    lsp-format.enable = true;
  };
}
