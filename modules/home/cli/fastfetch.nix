{ inputs, ... }:
{
  m.fastfetch =
    { pkgs, ... }:
    let
      logo = pkgs.writeText "nixos-logo.txt" ''
         _____  ___    __     ___  ___   ______    ________
        (\"   \|"  \  |" \   |"  \/"  | /    " \  /"       )
        |.\\   \    | ||  |   \   \  / // ____  \(:   \___/
        |: \.   \\  | |:  |    \\  \/ /  /    ) :)\___  \
        |.  \    \. | |.  |    /\.  \(: (____/ //  __/  \\
        |    \    \ | /\  |\  /  \   \\        /  /" \   :)
         \___|\____\)(__\_|_)|___/\___|\"_____/  (_______/

      '';
      fastfetch-config =
        pkgs.writeText "config.jsonc" # json
          ''
            {
              "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
              "logo": {
                "source": "${logo}",
                "type": "file",
                "height": 8,
                "color": {
                  "1": "#c5c0ff"
                },
                "padding": {
                  "top": 2,
                  "left": 2
                }
              },
              "display": {
                "separator": " ┈➤ "
              },
              "modules": [
                "break",
                {
                  "type": "title",
                  "keyWidth": 10,
                  "format": "         \u001b[38;2;197;192;255m{1}\u001b[38;2;168;200;240m@\u001b[38;2;200;176;232m{2}\u001b[0m"
                },
                {
                  "type": "custom",
                  "format": " ─────────────────────────── "
                },
                {
                  "type": "os",
                  "key": " ",
                  "keyColor": "#cfd3e7"
                },
                {
                  "type": "cpu",
                  "key": " ",
                  "keyColor": "#f4a8b8"
                },
                {
                  "type": "gpu",
                  "key": "󰢮 ",
                  "keyColor": "#ff7a6b"
                },
                {
                  "type": "memory",
                  "key": " ",
                  "keyColor": "#b8db8c",
                  "format": "{1} / {2}"
                },
                {
                  "type": "wm",
                  "key": " ",
                  "keyColor": "#7d75c0"
                },
                {
                  "type": "terminal",
                  "key": " ",
                  "keyColor": "#f6d88a"
                },
                {
                  "type": "custom",
                  "format": " ─────────────────────────── "
                },
                {
                  "type": "custom",
                  "format": "   \u001b[31m  \u001b[32m  \u001b[33m  \u001b[34m  \u001b[35m  \u001b[36m  \u001b[37m  \u001b[90m "
                },
                "break"
              ]
            }
          '';
    in
    {
      hj = {
        packages = [
          (inputs.wrappers.lib.wrapPackage {
            inherit pkgs;
            package = pkgs.fastfetch;
            flags = {
              "--config" = "${fastfetch-config}";
            };
          })
        ];
      };
    };
}
