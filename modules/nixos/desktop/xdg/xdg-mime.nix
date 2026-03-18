{
  flake.modules.nixos.desktop =
    { lib, ... }:
    with lib;
    let
      defaultApps = {
        text = [ "nvim.desktop" ];
        image = [
          "com.interversehq.qView.desktop"
        ];
        audio = [ "mpv.desktop" ];
        video = [ "mpv.desktop" ];
        directory = [ "foot.desktop" ];
        terminal = [ "foot.desktop" ];
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
          "image/svg+xml"
          "image/tiff"
          "image/vnd.microsoft.icon"
          "image/webp"
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

      associations =
        with lists;
        listToAttrs (
          flatten (mapAttrsToList (key: map (type: attrsets.nameValuePair type defaultApps."${key}")) mimeMap)
        );
    in
    {
      xdg = {
        mime = {
          enable = true;
          defaultApplications = associations;
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
