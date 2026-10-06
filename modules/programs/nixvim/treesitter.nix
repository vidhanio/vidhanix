{
  profiles.pc.homeModule =
    { config, ... }:
    {
      programs.nixvim.plugins.treesitter = {
        enable = true;
        highlight.enable = true;
        indent.enable = true;
        folding.enable = true;

        grammarPackages = with config.programs.nixvim.plugins.treesitter.package.builtGrammars; [
          # keep-sorted start
          bash
          c
          diff
          html
          javascript
          jsdoc
          json
          lua
          luadoc
          luap
          markdown
          markdown_inline
          nix
          printf
          python
          query
          regex
          rust
          toml
          tsx
          typescript
          typst
          vim
          vimdoc
          xml
          yaml
          # keep-sorted end
        ];
      };
    };
}
