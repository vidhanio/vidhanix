{
  profiles.pc.homeModule = _: {
    programs.nixvim = {
      extraFiles."lua/notebook-format.lua".source = ./lua/notebook-format.lua;
      extraConfigLua = "require('notebook-format').setup()";

      plugins.conform-nvim = {
        enable = true;
        autoInstall.enable = false;
        settings = {
          formatters_by_ft.ipynb = [ "treefmt" ];
          formatters_by_ft."_".__raw = ''
            function(buf)
              if require("notebook-format").is_notebook(buf) then
                return { "notebook_cells" }
              end
              return { "treefmt" }
            end
          '';
          formatters = {
            treefmt.require_cwd = false;
            notebook_cells.format.__raw = "require('notebook-format').format";
          };
          format_on_save = {
            timeout_ms = 500;
            lsp_fallback = true;
          };
        };
      };
    };
  };
}
