{ inputs, lib, ... }:
{
  flake-file.inputs.agentcord.url = "github:vidhanio/agentcord";

  flake.aspects.agentcord = {
    homeManager =
      { config, inputs', ... }:
      {
        imports = [ inputs.agentcord.homeManagerModules.default ];

        sops.secrets = {
          "agentcord/bot-token" = { };
          "agentcord/guild-id" = { };
          "agentcord/allowed-user-id" = { };
          "agentcord/forum-channel-id" = { };
        };

        sops.templates."agentcord-env".content = ''
          BOT_TOKEN=${config.sops.placeholder."agentcord/bot-token"}
          GUILD_ID=${config.sops.placeholder."agentcord/guild-id"}
          ALLOWED_USER_ID=${config.sops.placeholder."agentcord/allowed-user-id"}
          FORUM_CHANNEL_ID=${config.sops.placeholder."agentcord/forum-channel-id"}
        '';

        programs.agentcord = {
          enable = true;
          environmentFile = config.sops.templates."agentcord-env".path;
          settings = {
            discord = {
              bot_token = "\${BOT_TOKEN}";
              guild_id = "\${GUILD_ID}";
              allowed_user_id = "\${ALLOWED_USER_ID}";
              forum_channel_id = "\${FORUM_CHANNEL_ID}";
            };

            projects.base_path = "~/Projects";

            agents = {
              omp = {
                display_name = "Oh My Pi";
                command = "omp";
                args = [ "acp" ];
                emoji = "🥧";
              };
              opencode = {
                display_name = "OpenCode 2";
                command = "opencode2";
                args = [ "acp" ];
                emoji = "🧩";
              };
              prime = {
                display_name = "Prime Agent";
                command = "prime-agent";
                args = [
                  "--mode"
                  "acp"
                ];
                emoji = "👑";
              };
              codex = {
                display_name = "Codex";
                command = lib.getExe inputs'.llm-agents.packages.codex-acp;
                emoji = "🌀";
              };
            };
          };
        };

        persist.directories = [ ".local/state/agentcord" ];
      };
  };
}
