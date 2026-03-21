{ lib, ... }:
{
  flake.modules = {
    nixos.default = {
      environment.etc = {
        "1password/custom_allowed_browsers" = {
          text = ''
            helium
          '';
          mode = "0755";
        };
      };
    };
    homeManager.default =
      { osConfig, ... }:
      {
        xdg.configFile."net.imput.helium/NativeMessagingHosts/com.1password.1password.json".text =
          lib.toJSON
            {
              name = "com.1password.1password";
              description = "1Password BrowserSupport";
              path = "${osConfig.security.wrapperDir}/1Password-BrowserSupport";
              type = "stdio";
              allowed_origins = [
                "chrome-extension://hjlinigoblmkhjejkmbegnoaljkphmgo/"
                "chrome-extension://bkpbhnjcbehoklfkljkkbbmipaphipgl/"
                "chrome-extension://gejiddohjgogedgjnonbofjigllpkmbf/"
                "chrome-extension://khgocmkkpikpnmmkgmdnfckapcdkgfaf/"
                "chrome-extension://aeblfdkhhhdcdjpifhhbdiojplfjncoa/"
                "chrome-extension://dppgmdbiimibapkepcbdbmkaabgiofem/"
              ];
            };
      };
  };
}
