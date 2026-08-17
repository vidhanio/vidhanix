{
  flake.aspects.skills.homeManager =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.programs.agents.skills;

      defaultSkillsDir = "${config.home.homeDirectory}/.agents/skills";

      mkSkillEntry =
        name: content:
        if lib.hm.strings.isPathLike content && lib.pathIsDirectory content then
          lib.nameValuePair "${cfg.configDir}/${name}" {
            source = content;
            recursive = true;
          }
        else
          lib.nameValuePair "${cfg.configDir}/${name}/SKILL.md" (
            if lib.hm.strings.isPathLike content then { source = content; } else { text = content; }
          );
    in
    {
      options.programs.agents.skills = {
        enable = lib.mkEnableOption "the shared agent skills directory";

        configDir = lib.mkOption {
          type = lib.types.str;
          default = defaultSkillsDir;
          defaultText = lib.literalExpression ''"''${config.home.homeDirectory}/.agents/skills"'';
          description = ''
            Directory holding the shared agent skills.

            Defaults to {file}`~/.agents/skills`, the conventional location
            for skills shared across agents (see the Agent Skills
            specification). Agents discover skills there by convention;
            if you change this, point your agents at the new location
            yourself.
          '';
        };

        skills = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.oneOf [
              lib.types.lines
              lib.types.path
              lib.types.str
            ]
          );
          default = { };
          example = lib.literalExpression ''
            {
              pdf-processing = '''
                ---
                name: pdf-processing
                description: Extract text and tables from PDF files, fill forms, merge documents.
                ---

                # PDF Processing

                Use pdfplumber to extract text from PDFs.
              ''';
              xlsx = ./skills/xlsx/SKILL.md;
              data-analysis = ./skills/data-analysis;
              mattpocock = inputs.mattpocock-skills + "/skills";
            }
          '';
          description = ''
            Custom skills for the agents.

            The attribute name becomes the skill directory name, and the
            value is either:
            - Inline content as a string (creates {file}`skills/<name>/SKILL.md`)
            - A path to a file (creates {file}`skills/<name>/SKILL.md`)
            - A path to a directory (creates {file}`skills/<name>/` with all files)

            This also accepts Nix store paths, for example a skill directory
            from a package.

            A directory that holds a whole collection of skills, such as a
            skills repository, is symlinked under the attribute name as well;
            each skill folder inside it stays reachable at
            {file}`skills/<name>/<skill>/SKILL.md`.

            The skills are written into
            {option}`programs.agents.skills.configDir`.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        home.file = lib.mapAttrs' mkSkillEntry cfg.skills;
      };
    };
}
