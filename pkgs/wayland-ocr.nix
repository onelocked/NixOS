{
  writeShellApplication,
  grim,
  libnotify,
  slurp,
  tesseract5,
  wl-clipboard-rs,
  langs ? "eng+rus",
}:

writeShellApplication {
  name = "ocr";

  runtimeInputs = [
    grim
    libnotify
    slurp
    tesseract5
    wl-clipboard-rs
  ];

  text = # bash
    ''
      selection=$(slurp 2>/dev/null || true)

      if [ -z "$selection" ]; then
        notify-send "OCR" "Cancelled by user"
        exit 0
      fi

      grim -g "$selection" -t ppm - \
        | tesseract -l "${langs}" - - \
        | wl-copy

      notify-send "OCR" "Text copied to clipboard"
    '';
}
