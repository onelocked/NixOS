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
        journald.storage = "volatile";
      };
      # Enable CUPS to print documents.
      services.printing.enable = false;
      # Enable touchpad support (enabled default in most desktopManager).
      services.libinput.enable = true;
      # Setup keyring
      services.gnome.gnome-keyring.enable = true;
      programs.seahorse.enable = true;
      #Xserver
      services.xserver.enable = pkgs.lib.mkForce false;
      #Polkit
      security.polkit.enable = true;
    };
}
