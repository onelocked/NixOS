{
  writeShellScriptBin,
  ripgrep,
  wl-clipboard-rs,
  mpv,
}:

writeShellScriptBin "mpv-wlpaste" ''
  url="$(${wl-clipboard-rs}/bin/wl-paste || true)"

  [ -z "$url" ] && exit 0

  if echo "$url" | ${ripgrep}/bin/rg -q '(^https?://)?([^/]*\.)?tiktok\.com/'; then
    url="''${url%%\?*}"
  fi

  exec ${mpv}/bin/mpv "$url"
''
