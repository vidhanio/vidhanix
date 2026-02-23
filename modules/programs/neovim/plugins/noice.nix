{
  flake.modules.nixvim.default.plugins.noice = {
    enable = true;
    settings = {
      lsp.override = {
        "vim.lsp.util.convert_input_to_markdown_lines" = true;
        "vim.lsp.util.stylize_markdown" = true;
        "cmp.entry.get_documentation" = true;
      };
      cmdline.view = "cmdline";
    };
  };
}
