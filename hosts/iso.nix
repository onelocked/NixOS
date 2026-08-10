{
  exo.configurations = {
    #nixosConfigurations.iso-image.config.system.build.isoImage
    iso-image = {
      bare = true;
      system = "x86_64-linux";
      modules = [
        (
          {
            pkgs,
            modulesPath,
            lib,
            ...
          }:
          {
            imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];
            isoImage.squashfsCompression = "gzip -Xcompression-level 1";
            users.users.root.openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICkCeWsgSWc7pbDNm3rpBg6nmK7DEjI/6TrZaKR3ueOr shorekeeper"
            ];
            environment.systemPackages = with pkgs; [
              git
              neovim
              sops
              yazi
            ];
            services.openssh = {
              enable = true;
              settings.PermitRootLogin = "prohibit-password";
            };
            programs.nano.enable = false;
            nix.settings.experimental-features = [
              "nix-command"
              "flakes"
              "pipe-operators"
            ];
            programs.command-not-found.enable = lib.mkForce false;
          }
        )
      ];
    };
  };
}
