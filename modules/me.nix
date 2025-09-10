{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.me = {
    fullname = mkOption {
      type = with types; str;
      default = "Vidhan Bhatt";
      description = "Your full name.";
    };
    username = mkOption {
      type = with types; str;
      default = "vidhanio";
      description = "Your username.";
    };
    email = mkOption {
      type = with types; str;
      default = "me@vidhan.io";
      description = "Your email address.";
    };
    host = mkOption {
      type = with types; str;
      description = "The hostname of this machine.";
    };
  };
}
