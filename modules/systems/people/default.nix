{ lib, ... }:
{
  options.people = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          fullName = lib.mkOption {
            type = lib.types.str;
            description = "The full name of the person.";
          };
          email = lib.mkOption {
            type = lib.types.str;
            description = "The email address of the person.";
          };
          extraPublicKeys = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "SSH public keys for this person not tied to any particular host.";
          };
        };
      }
    );
    default = { };
    description = "Identity metadata for people referenced by den users.";
  };
}
