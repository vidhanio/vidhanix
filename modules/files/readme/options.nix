{
  flake-parts-lib,
  lib,
  ...
}:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { pkgs, config, ... }:
    let
      cfg = config.files.readme;
    in
    {
      options.files.readme =
        let
          section =
            level:
            lib.types.submodule (
              { name, config, ... }:
              {
                options = {
                  level = lib.mkOption {
                    type = lib.types.int;
                    default = level;
                    description = "The heading level for the README content.";
                    readOnly = true;
                  };
                  title = lib.mkOption {
                    type = lib.types.str;
                    description = "The title of this section.";
                    default = name;
                    apply = lib.trim;
                  };
                  order = lib.mkOption {
                    type = lib.types.listOf lib.types.str;
                    description = "The order of sections within `contents`.";
                    readOnly = true;
                  };
                  content = lib.mkOption {
                    type =
                      if level == 6 then
                        lib.types.lines
                      else
                        lib.types.either lib.types.lines (lib.types.attrsOf (section (level + 1)));
                    default = "";
                    description = "The content for this section. If the level is less than 6, this can be further subsections.";
                  };
                  rendered = lib.mkOption {
                    type = lib.types.str;
                    description = "The rendered markdown content for this section.";
                    readOnly = true;
                    default =
                      let
                        renderedContent = lib.trim (
                          if lib.isAttrs config.content then
                            lib.concatMapStringsSep "\n\n" (sectionName: config.content.${sectionName}.rendered) config.order
                          else
                            config.content
                        );

                      in
                      (lib.strings.replicate config.level "#")
                      + " "
                      + config.title
                      + (if renderedContent == "" then "" else "\n\n")
                      + renderedContent;
                  };
                }
                // lib.optionalAttrs (level == 1) {
                  lib = lib.mkOption {
                    type = lib.types.attrs;
                    description = "Helpers for generating README content.";
                  };
                };
              }
            );
        in
        lib.mkOption {
          description = "Configuration for generating the README.md file.";
          type = section 1;
        };

      config = {
        files.readme = {
          lib.renderTable =
            let
              renderRow = row: "| " + (lib.concatStringsSep " | " row) + " |";
            in
            { header, rows }:
            assert lib.assertMsg (lib.all (
              row: lib.length row == lib.length header
            ) rows) "All rows must have the same number of columns as the header.";
            lib.concatMapStringsSep "\n" renderRow (
              [
                header
                (lib.lists.replicate (lib.length header) "---")
              ]
              ++ rows
            );
        };

        files.file."README.md".text = cfg.rendered;
      };
    }
  );
}
