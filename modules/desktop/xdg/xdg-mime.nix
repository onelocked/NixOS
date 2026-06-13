{
  exo.mods.desktop =
    { lib, constants, ... }:
    with lib;
    let
      defaultApps = {
        text = [ "nvim.desktop" ];
        image = [ "mpvi.desktop" ];
        svg = [ "com.interversehq.qView.desktop" ];
        audio = [ "mpv.desktop" ];
        video = [ "mpv.desktop" ];
        directory = [ constants.terminal ];
        terminal = [ constants.terminal ];
      };

      mimeMap = {
        text = [
          "text/plain"
          "text/x-python"
          "text/x-shellscript"
        ];
        image = [
          "image/bmp"
          "image/gif"
          "image/jpeg"
          "image/jpg"
          "image/png"
          "image/tiff"
          "image/vnd.microsoft.icon"
          "image/webp"
        ];
        svg = [
          "image/svg+xml"
        ];
        audio = [
          "audio/aac"
          "audio/mpeg"
          "audio/ogg"
          "audio/opus"
          "audio/wav"
          "audio/webm"
          "audio/x-matroska"
        ];
        video = [
          "video/mp2t"
          "video/mp4"
          "video/mpeg"
          "video/ogg"
          "video/webm"
          "video/x-flv"
          "video/x-matroska"
          "video/x-msvideo"
        ];
        directory = [ "inode/directory" ];
        terminal = [
          "terminal"
          "x-terminal-emulator"
          "application/x-shellscript"
        ];
      };

      defaultApplications =
        mimeMap
        |> mapAttrsToList (key: map (type: nameValuePair type defaultApps."${key}"))
        |> flatten
        |> listToAttrs;
    in
    {
      xdg = {
        mime = {
          enable = true;
          inherit defaultApplications;
          addedAssociations = {
            "x-scheme-handler/mpv-handler" = [ "mpv-handler.desktop" ];
            "x-scheme-handler/mpv-handler-debug" = [ "mpv-handler-debug.desktop" ];
            "x-scheme-handler/discord" = [ "vesktop.desktop" ];
            "x-scheme-handler/tg" = [ "telegram.desktop" ];
          };
        };
      };
    };
}
