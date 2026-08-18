{
  flake.aspects.omp = {
    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        cfg = config.programs.omp;
        yaml = pkgs.formats.yaml { };
        json = pkgs.formats.json { };

        mkResourceOption =
          { dir, description }:
          lib.mkOption {
            type = lib.types.either (lib.types.attrsOf (
              lib.types.oneOf [
                lib.types.lines
                lib.types.path
                lib.types.str
              ]
            )) lib.types.path;
            default = { };
            description = ''
              ${description}

              Either an attribute set of resources or a path to a directory,
              symlinked to {file}`~/.omp/agent/${dir}/`.
            '';
          };

        normalizeDirectory =
          name: option: source:
          if lib.isPath source then
            source
          else
            pkgs.runCommandLocal name { } ''
              source=${lib.escapeShellArg (toString source)}
              if [[ ! -d "$source" ]]; then
                echo ${lib.escapeShellArg "programs.omp.${option} must be a directory"} >&2
                exit 1
              fi
              ln -s "$source" "$out"
            '';

        normalizeSkill =
          source:
          pkgs.runCommandLocal "omp-skill" { } ''
            source=${lib.escapeShellArg (toString source)}
            if [[ -d "$source" ]]; then
              ln -s "$source" "$out"
            elif [[ -f "$source" ]]; then
              mkdir "$out"
              ln -s "$source" "$out/SKILL.md"
            else
              echo "skill source must be a file or directory: $source" >&2
              exit 1
            fi
          '';

        resourceFiles =
          dir: suffix: resources:
          let
            attrs = if lib.isAttrs resources then resources else { };
          in
          (lib.optionalAttrs (lib.hm.strings.isPathLike resources) {
            ".omp/agent/${dir}" = {
              source = normalizeDirectory "omp-${dir}" dir resources;
              recursive = true;
            };
          })
          // lib.mapAttrs' (
            name: content:
            if lib.isPath content && lib.pathIsDirectory content then
              lib.nameValuePair ".omp/agent/${dir}/${name}" {
                source = content;
                recursive = true;
              }
            else if dir == "skills" && lib.hm.strings.isPathLike content && !lib.isPath content then
              lib.nameValuePair ".omp/agent/${dir}/${name}" {
                source = normalizeSkill content;
                recursive = true;
              }
            else
              lib.nameValuePair ".omp/agent/${dir}/${name}${suffix}" (
                if lib.hm.strings.isPathLike content then { source = content; } else { text = content; }
              )
          ) attrs;

        resourceAssertion =
          { dir, resources }:
          {
            assertion = !lib.isPath resources || lib.pathIsDirectory resources;
            message = "`programs.omp.${dir}` must be a directory when set to a path";
          };

        toOmpServer =
          server:
          lib.hm.mcp.transformMcpServer {
            inherit server;
            extraTransforms = [ lib.hm.mcp.addType ];
            mkFileRef = path: "!cat ${lib.escapeShellArg path}";
          };

        transformedMcpServers = lib.optionalAttrs (cfg.enableMcpIntegration && config.programs.mcp.enable) (
          lib.mapAttrs (_: toOmpServer) config.programs.mcp.servers
        );

        mcpServers = transformedMcpServers // cfg.mcpServers;
      in
      {
        options.programs.omp = {
          enable = lib.mkEnableOption "Oh My Pi";

          package = lib.mkPackageOption pkgs "omp" { nullable = true; };

          settings = lib.mkOption {
            inherit (yaml) type;
            default = { };
            example = {
              theme.dark = "titanium";
              symbolPreset = "nerd";
              modelRoles.default = "anthropic/claude-sonnet-4-5";
              tools.approvalMode = "write";
              memory.backend = "off";
            };
            description = ''
              Configuration written to {file}`~/.omp/agent/config.yml`.
              See <https://omp.sh/docs/settings> for the documentation.
            '';
          };

          models = lib.mkOption {
            inherit (yaml) type;
            default = { };
            example = {
              providers.opencode-go.modelOverrides.deepseek-v4-flash.thinking = {
                mode = "effort";
                efforts = [
                  "low"
                  "high"
                  "max"
                ];
              };
            };
            description = ''
              Model and provider configuration written to
              {file}`~/.omp/agent/models.yml`.
              See <https://omp.sh/docs/models> for the documentation.
            '';
          };

          enableMcpIntegration = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              Whether to integrate the MCP servers config from
              {option}`programs.mcp.servers` into
              {option}`programs.omp.mcpServers`, written to
              {file}`~/.omp/agent/mcp.json`.

              Note: Servers defined in {option}`programs.mcp.servers` are merged
              with {option}`programs.omp.mcpServers`, with explicit omp settings
              taking precedence.
            '';
          };

          mcpServers = lib.mkOption {
            inherit (json) type;
            default = { };
            example = {
              filesystem = {
                command = "npx";
                args = [
                  "-y"
                  "@modelcontextprotocol/server-filesystem"
                ];
              };
            };
            description = ''
              MCP servers written to {file}`~/.omp/agent/mcp.json`.
              See <https://omp.sh/docs/mcp-config> for the documentation.
            '';
          };

          keybindings = lib.mkOption {
            inherit (yaml) type;
            default = { };
            example = {
              "app.model.cycleForward" = "Ctrl+P";
              "app.history.search" = [ ];
            };
            description = ''
              Keybinding remaps written to {file}`~/.omp/agent/keybindings.yml`.
              See <https://omp.sh/docs/keybindings> for the documentation.
            '';
          };

          context = lib.mkOption {
            type = lib.types.either lib.types.lines lib.types.path;
            default = "";
            description = ''
              Global context for Oh My Pi.

              The value is either:
              - Inline content as a string
              - A path to a file containing the content

              The configured content is written to {file}`~/.omp/agent/AGENTS.md`.
            '';
            example = "Prefer the project-local AGENTS.md; escalate to the user before editing system files.";
          };

          themes = lib.mkOption {
            type = lib.types.either (lib.types.attrsOf (lib.types.either json.type lib.types.path)) lib.types.path;
            default = { };
            example = {
              stylix = {
                name = "stylix";
                colors.accent = "#00aaff";
              };
            };
            description = ''
              Custom themes for Oh My Pi.

              This option can either be:
              - An attribute set defining themes
              - A path to a directory containing multiple theme files

              If an attribute set is used, the attribute name becomes the theme filename,
              and the value is either:
              - An attribute set that is converted to a JSON file
              - A path to a file

              If a path is used, it is expected to contain theme files.
              The directory is symlinked to {file}`~/.omp/agent/themes/`.

              A `$schema` key and the theme `name` are added automatically.

              Set {option}`programs.omp.settings.theme.dark` to enable a theme.
            '';
          };

          commands = mkResourceOption {
            dir = "commands";
            description = ''
              Custom command for Oh My Pi.

              This option can either be:
              - An attribute set defining commands
              - A path to a directory containing multiple commands files

              If an attribute set is used, the attribute name becomes the command filename,
              and the value is either:
              - Inline content as a string (creates `opencode/commands/<name>.md`)
              - A path to a file (creates `opencode/commands/<name>.md`)

              If a path is used, it is expected to contain commands files.
              The directory is symlinked to {file}`~/.omp/agent/commands/`.
            '';
          };

          skills = mkResourceOption {
            dir = "skills";
            description = ''
              Custom skills for Oh My Pi.

              This option can be either:
              - An attribute set defining skills
              - A path to a directory containing skill folders

              If an attribute set is used, the attribute name becomes the
              skill directory name, and the value is either:
              - Inline content as a string (creates `~/.omp/agent/skills/<name>/SKILL.md`)
              - A path to a file (creates `~/.omp/agent/skills/<name>/SKILL.md`)
              - A path to a directory (creates `~/.omp/agent/skills/<name>/` with all files)

              This also accepts Nix store paths, for example a skill directory from
              a package.

              If a path is used, it is expected to contain one folder per skill name,
              each containing a {file}`SKILL.md`. The directory is symlinked to
              {file}`~/.omp/agent/skills/`.
            '';
          };

          prompts = mkResourceOption {
            dir = "prompts";
            description = ''
              Custom prompt template for Oh My Pi.

              This option can either be:
              - An attribute set defining prompt templates
              - A path to a directory containing multiple prompt templates files

              If an attribute set is used, the attribute name becomes the prompt template filename,
              and the value is either:
              - Inline content as a string (creates `opencode/prompts/<name>.md`)
              - A path to a file (creates `opencode/prompts/<name>.md`)

              If a path is used, it is expected to contain prompt templates files.
              The directory is symlinked to {file}`~/.omp/agent/prompts/`.
            '';
          };

          tools = mkResourceOption {
            dir = "tools";
            description = ''
              Custom tool for Oh My Pi.

              This option can either be:
              - An attribute set defining tools
              - A path to a directory containing multiple tools files

              If an attribute set is used, the attribute name becomes the tool filename,
              and the value is either:
              - Inline content as a string (creates `opencode/tools/<name>.ts`)
              - A path to a file (creates `opencode/tools/<name>.ts`)

              If a path is used, it is expected to contain tools files.
              The directory is symlinked to {file}`~/.omp/agent/tools/`.
            '';
          };
        };

        config = lib.mkIf cfg.enable {
          home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];

          home.file = {
            ".omp/agent/config.yml" = lib.mkIf (cfg.settings != { }) {
              source = yaml.generate "omp-config.yml" cfg.settings;
            };

            ".omp/agent/models.yml" = lib.mkIf (cfg.models != { }) {
              source = yaml.generate "omp-models.yml" cfg.models;
            };

            ".omp/agent/mcp.json" = lib.mkIf (mcpServers != { }) {
              source = json.generate "omp-mcp.json" { inherit mcpServers; };
            };

            ".omp/agent/keybindings.yml" = lib.mkIf (cfg.keybindings != { }) {
              source = yaml.generate "omp-keybindings.yml" cfg.keybindings;
            };

            ".omp/agent/AGENTS.md" =
              if lib.isPath cfg.context then
                { source = cfg.context; }
              else
                lib.mkIf (cfg.context != "") {
                  text = cfg.context;
                };
          }
          // (lib.optionalAttrs (lib.hm.strings.isPathLike cfg.themes) {
            ".omp/agent/themes" = {
              source = cfg.themes;
              recursive = true;
            };
          })
          // lib.mapAttrs' (
            name: content:
            lib.nameValuePair ".omp/agent/themes/${name}.json" (
              if lib.isPath content then
                { source = content; }
              else
                {
                  source = json.generate "omp-${name}.json" (
                    {
                      "$schema" =
                        "https://raw.githubusercontent.com/can1357/oh-my-pi/main/packages/coding-agent/theme-schema.json";
                      inherit name;
                    }
                    // content
                  );
                }
            )
          ) (if lib.isAttrs cfg.themes then cfg.themes else { })
          // resourceFiles "commands" ".md" cfg.commands
          // resourceFiles "skills" "/SKILL.md" cfg.skills
          // resourceFiles "prompts" ".md" cfg.prompts
          // resourceFiles "tools" ".ts" cfg.tools;

          assertions = map resourceAssertion [
            {
              dir = "commands";
              resources = cfg.commands;
            }
            {
              dir = "skills";
              resources = cfg.skills;
            }
            {
              dir = "prompts";
              resources = cfg.prompts;
            }
            {
              dir = "tools";
              resources = cfg.tools;
            }
            {
              dir = "themes";
              resources = cfg.themes;
            }
          ];
        };
      };
  };
}
