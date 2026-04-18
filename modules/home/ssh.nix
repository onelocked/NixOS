{
  flake.modules.nixos.default = {
    hj.files.".ssh/config".text = # bash
      ''
        Host Raspberry
          User onelock
          HostName 192.168.1.239

        Host gitea.onelock.org
          Port 2222
          IdentitiesOnly yes
          User git
          HostName gitea.onelock.org
          IdentityFile ~/.ssh/id_ed25519_gitea

        Host github.com
          IdentitiesOnly yes
          User git
          HostName github.com
          IdentityFile ~/.ssh/id_ed25519_github

        Host router
          User root
          HostName 192.168.1.1
      '';
  };
}
