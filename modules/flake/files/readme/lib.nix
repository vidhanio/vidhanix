{ flake-parts-lib, lib, ... }:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption {
    config.files.lib.readme = {
      renderTable =
        {
          header,
          alignments ? (lib.lists.replicate (lib.length header) "l"),
          rows,
        }:
        let
          renderRow = row: "| " + (lib.concatStringsSep " | " row) + " |";
          getAlignmentText =
            char:
            {
              l = ":---";
              c = ":---:";
              r = "---:";
            }
            .${char} or (throw "invalid alignment character: ${char} (must be one of 'l', 'c', 'r')");
        in
        assert lib.assertMsg (lib.all (
          row: lib.length row == lib.length header
        ) rows) "All rows must have the same number of columns as the header.";
        lib.concatMapStringsSep "\n" renderRow (
          [
            header
            (map getAlignmentText alignments)
          ]
          ++ rows
        );

      renderList =
        items:
        let
          renderBullet = indent: item: (lib.strings.replicate indent "  ") + "- " + item;
          toBullets =
            indent: items:
            lib.concatMap (
              item: if lib.isList item then toBullets (indent + 1) item else [ (renderBullet indent item) ]
            ) items;
        in
        lib.concatStringsSep "\n" (toBullets 0 items);
    };
  };
}
