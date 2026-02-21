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
writeShellScriptBin "ocr" #bash

''
  selection="$(${_ slurp} || true)"

  if [ -z "$selection" ]; then
    ${_ libnotify} -- "OCR Cancelled by user"
    exit 0
  fi

  ${_ grim} -g "$selection" -t ppm - \
    | ${_ tesseract5} -l ${langs} - - \
    | ${wl-clipboard-rs}/bin/wl-copy

  ${_ libnotify} -- "OCR copied to clipboard"
''
