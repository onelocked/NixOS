{
  writeShellScriptBin,
  wl-clipboard-rs,
  mpv,
  coreutils,
}:

writeShellScriptBin "mpv-wlpaste" ''
  url=$(${wl-clipboard-rs}/bin/wl-paste | ${coreutils}/bin/tr -d '[:space:]')
  if [ -z "$url" ]; then
    exit 0
  fi
  case "$url" in
    *tiktok.com*)
      url="''${url%%\?*}"
      ;;
  esac
  exec ${mpv}/bin/mpv "$url"
''
