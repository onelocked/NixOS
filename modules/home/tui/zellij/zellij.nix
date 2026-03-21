{
  flake.modules.homeManager.zellij =
    { pkgs, ... }:
    {
      programs.zellij = {
        enable = true;
        settings = {
          session_serialization = false;
          default_mode = "locked";
          mouse_mode = true;
          advanced_mouse_actions = false;
          copy_command = "${pkgs.wl-clipboard-rs}/bin/wl-copy";
          copy_on_select = true;
          show_startup_tips = false;
          pane_frames = false;
          ui.pane_frames.hide_session_name = true;
          ui.pane_frames.rounded_corners = true;
        };
      };
    };
}
