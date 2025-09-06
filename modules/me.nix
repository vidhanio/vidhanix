{ lib, ... }:
{
  options.me = {
    fullname = lib.mkOption {
      type = with lib.types; str;
      default = "Vidhan Bhatt";
      description = "Your full name.";
    };
    username = lib.mkOption {
      type = with lib.types; str;
      default = "vidhanio";
      description = "Your username.";
    };
    email = lib.mkOption {
      type = with lib.types; str;
      default = "me@vidhan.io";
      description = "Your email address.";
    };
    host = lib.mkOption {
      type = with lib.types; str;
      description = "The hostname of this machine.";
    };
  };
}
