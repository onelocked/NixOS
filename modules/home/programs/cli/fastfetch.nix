{
  flake.modules.homeManager.fastfetch = {
    programs.fastfetch = {
      enable = true;
    };
    xdg.configFile."fastfetch/config.jsonc".text = # json
      ''
        {
        "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
         "logo": {
          "source": "~/.config/fastfetch/images/*.png",
          "type": "sixel",
          "height": 10,
          "width": 20,
          "padding": {
            "top": 1
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
        			"format": "         {6}{7}{8}"
                },
                {
                    "type": "custom",
                    "format": " ─────────────────────────── "
                },
                {
                    "type": "os",
                    "key": " ",
                    "keyColor": "white"
                },
                {
                    "type": "cpu",
                    "key": " ",
                    "keyColor": "red"
                },
                                {
                    "type": "gpu",
                    "key": "󰢮 ",
                    "keyColor": "magenta"
                },


                {
                    "type": "memory",
                    "key": " ",
                    "keyColor": "green",
                    // format: used / total
                    "format": "{1} / {2}"
                },

                {
                    "type": "wm",
                    "key": " ",
                    "keyColor": "blue"
                },
                {
                    "type": "terminal",
                    "key": " ",
                    "keyColor": "yellow"
                },
                /*
                {
                    "type": "packages",
                    "key": "󰏖 ",
                    "keyColor": "yellow"
                },
                */
                {
                    "type": "custom",
                    "format": " ─────────────────────────── "
                },
                {
                    "type": "custom",
                    "format": "   \u001b[31m  \u001b[32m  \u001b[33m  \u001b[34m  \u001b[35m  \u001b[36m  \u001b[37m  \u001b[90m "
                },
        		"break",
            ]
        }
      '';
  };
}
