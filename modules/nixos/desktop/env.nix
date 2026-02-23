{
  flake.nixosModules.desktop = {
    environment.sessionVariables = {
      XDG_CURRENT_DESKTOP = "niri";
      XDG_SESSION_DESKTOP = "niri";
      XDG_SESSION_TYPE = "wayland";

      GDK_BACKEND = "wayland";
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      MOZ_ENABLE_WAYLAND = "1";

      OZONE_PLATFORM = "wayland";
      EGL_PLATFORM = "wayland";
      CLUTTER_BACKEND = "wayland";
      SDL_VIDEODRIVER = "wayland";

      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_ENABLE_HIGHDPI_SCALING = "1";

      QS_ICON_THEME = "Papirus-Dark";
      GTK_THEME = "adw-gtk3-dark";
      GTK_USE_PORTAL = "1";

      WLR_RENDERER_ALLOW_SOFTWARE = "0";
      WLR_RENDERER = "vulkan";

      LIBVA_DRIVER_NAME = "radeonsi";
    };
  };
}
