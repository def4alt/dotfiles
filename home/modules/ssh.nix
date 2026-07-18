{ lib, platform, ... }:
let
  isDarwin = lib.hasSuffix "darwin" platform;
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    # OrbStack requires its Include directive before any Host blocks.
    includes = lib.optionals isDarwin [ "~/.orbstack/ssh/config" ];

    settings = {
      "*" = lib.optionalAttrs isDarwin {
        IdentityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
      };

      halle = {
        Hostname = "lxhalle.in.tum.de";
        User = "olkh";
      };
    };
  };
}
