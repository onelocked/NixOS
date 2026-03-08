{
  flake.modules.homeManager.matugen =
    { config, ... }:
    {
      xdg.configFile."noctalia/user-templates.toml".text = ''
        [config]

        [templates]

        [templates.lazygit]
        input_path = '${./templates/lazygit.yml}'
        output_path = '${config.xdg.configHome}/lazygit/config.yml'

      '';
    };
}
