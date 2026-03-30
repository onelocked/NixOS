{
  flake.modules.homeManager.default = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "gitea.onelock.org" = {
          hostname = "gitea.onelock.org";
          user = "git";
          identityFile = "~/.ssh/id_ed25519_gitea";
          identitiesOnly = true;
          port = 2222;
        };
        "github.com" = {
          hostname = "github.com";
          user = "git";
          identityFile = "~/.ssh/id_ed25519_github";
          identitiesOnly = true;
        };
        "Raspberry" = {
          hostname = "192.168.1.239";
          user = "onelock";
        };
        "router" = {
          hostname = "192.168.1.1";
          user = "root";
        };
      };
    };
  };
}
