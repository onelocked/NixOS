{ inputs, self, ... }:
{
  flake.nixosConfigurations.iso = inputs.nixpkgs.lib.nixosSystem {
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
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIOmu2dOoflLjxNCBPLsUxP7A/jQbyV9V+EgGS8rFPat iso-image"
          ];
          environment.systemPackages = with pkgs; [
            git
            neovim
            sops
            yazi
          ];
          environment.variables.TERM = "xterm-256color";
          services.openssh = {
            enable = true;
            settings.PermitRootLogin = "prohibit-password";
          };
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
  perSystem.legacyPackages.iso-image = self.nixosConfigurations.iso.config.system.build.isoImage;
}
