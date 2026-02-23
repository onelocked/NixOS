{
  flake.modules.nixos.core =
    { pkgs, ... }:
    {
      services = {
        devmon.enable = false;
        gvfs.enable = false;
        udisks2.enable = false;

        scx = {
          enable = true;
          package = pkgs.scx.rustscheds;
          scheduler = "scx_rusty"; # https://github.com/sched-ext/scx/blob/main/scheds/rust/README.md
        };
        printing.enable = false;
        gnome.gnome-keyring.enable = true;
        xserver.enable = pkgs.lib.mkForce false;
        journald.storage = "volatile";
      };
      programs.seahorse.enable = true;
      security.polkit.enable = true;
    };
}
