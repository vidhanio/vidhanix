_: {
  flake.modules.homeManager.default = _: {
    programs.pi-coding-agent = {
      enable = true;

      settings = {
        defaultProvider = "opencode-go";
        defaultModel = "deepseek-v4-flash";
        defaultThinkingLevel = "max";
        hideThinkingBlock = true;
      };
    };

    # pi has no update-check setting in settings.json; the equivalent of
    # the other agents' autoupdate/checkUpdate = false is disabling the
    # version check with the environment variable.
    home.sessionVariables.PI_SKIP_VERSION_CHECK = "1";

    persist.directories = [ ".pi/agent" ];
  };
}
