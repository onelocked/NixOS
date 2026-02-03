{
  writeShellScriptBin,
  wl-clipboard-rs,
  mpv,
}:

writeShellScriptBin "mpv-wlpaste" ''
  url="$(${wl-clipboard-rs}/bin/wl-paste || true)"

  [ -z "$url" ] && exit 0

  case "$url" in
    *tiktok.com/*\?*)
      url="''${url%%\?*}"
      ;;
  esac

  exec ${mpv}/bin/mpv "$url"
''
