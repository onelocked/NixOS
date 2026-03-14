{
  writeShellApplication,
  jq,
  uutils-coreutils-noprefix,
  util-linux,
}:
writeShellApplication {
  name = "niri-launcher";
  runtimeInputs = [
    jq
    uutils-coreutils-noprefix
    util-linux
  ];
  text = # bash
    ''
      APP_ID="$1"
      CMD="$2"
      WIN_ID=$(niri msg --json windows | jq -r ".[] | select(.app_id == \"$APP_ID\") | .id" | head -n1)
      if [ -z "$WIN_ID" ]; then
          setsid "$CMD" >/dev/null 2>&1 &
      else
          niri msg action focus-window --id "$WIN_ID"
      fi
    '';
}
