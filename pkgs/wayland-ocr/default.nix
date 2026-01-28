{
  writeShellScriptBin,
  lib,
  grim,
  libnotify,
  slurp,
  tesseract5,
  wl-clipboard-rs,
  langs ? "eng+rus",
}:
let
  _ = lib.getExe;
in
writeShellScriptBin "ocr" ''
  if selection="$(${_ slurp})"; then
    if [ -n "$selection" ]; then
      ${_ grim} -g "$selection" -t ppm - | ${_ tesseract5} -l ${langs} - - | ${wl-clipboard-rs}/bin/wl-copy
      ${_ libnotify} -- "OCR Copied to clipboard"
    else
      ${_ libnotify} -- "OCR Cancelled by user"
    fi
  else
    ${_ libnotify} -- "OCR Cancelled by user"
  fi
''
