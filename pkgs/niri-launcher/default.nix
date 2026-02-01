{
  lib,
  writeShellScriptBin,
  jq,
  coreutils,
  util-linux,
}:

let
  _ = lib.getExe;
in

writeShellScriptBin "launcher" ''
  APP_ID="$1"
  CMD="$2"

  WIN_ID=$(niri msg --json windows | ${_ jq} -r ".[] | select(.app_id == \"$APP_ID\") | .id" | ${coreutils}/bin/head -n1)

  if [ -z "$WIN_ID" ]; then
      ${util-linux}/bin/setsid $CMD >/dev/null 2>&1 &
  else
      niri msg action focus-window --id $WIN_ID
  fi
''
