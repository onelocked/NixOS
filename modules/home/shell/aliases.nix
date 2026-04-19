{ inputs, ... }:
{
  m.default =
    {
      pkgs,
      lib,
      ...
    }:
    let
      tomlFormat = pkgs.formats.toml { };
      atuin = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.atuin;
        env.ATUIN_CONFIG_DIR = pkgs.linkFarm "atuin-config" [
          {
            name = "config.toml";
            path = tomlFormat.generate "config.toml" {
              enter_accept = true;
              filter_mode = "session-preload";
              search_mode = "fuzzy";
            };
          }
        ];
      };
    in
    {
      environment.shellAliases =
        let
          _ = lib.getExe;
        in
        with pkgs;
        {
          ping = "${_ gping}";
          cat = "${_ bat}";
          zip = "${_ zip}";
          gtop = "${_ amdgpu_top} --dark";
          gr = "cd (git rev-parse --show-toplevel)";
          shot = "${wl-clipboard-rs}/bin/wl-paste | , silicon --language nix --to-clipboard --shadow-blur-radius 30 --pad-horiz 20 --pad-vert 20 --theme 'Visual Studio Dark+'";
        };
      hj.packages = [ atuin ];
      programs = {
        pay-respects.enable = true;
        fish.interactiveShellInit = ''
          ${lib.getExe pkgs.pay-respects} fish | source
          ${lib.getExe pkgs.nix-your-shell} fish | source
          ${lib.getExe pkgs.carapace} _carapace fish | source
          ${lib.getExe atuin} init fish | source
        '';
        zoxide = {
          enable = true;
          enableFishIntegration = true;
        };
      };
    };
}
