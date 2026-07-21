{
  exo.core =
    {
      pkgs,
      wrapPackage,
      theme,
      lib,
      config,
      ...
    }:
    let
      cfg = config.forte.bat;
    in
    {
      config = lib.mkIf cfg.enable {
        hj.packages = [ cfg.package ];
        environment.shellAliases = {
          cat = "${cfg.package}/bin/bat";
          man = "${cfg.package}/bin/batman --paging=auto";
        };
      };
      options.forte.bat = {
        enable = lib.mkEnableOption "bat" // {
          default = true;
        };
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.symlinkJoin {
            name = "bat";
            paths = [
              (wrapPackage {
                package = pkgs.bat;
                args = [
                  "--theme ${(if theme == "dark" then "TwoDark" else "base16")}"
                  "--style=plain"
                ];
              })
              (pkgs.bat-extras.batman.overrideAttrs (oldAttrs: {
                postInstall =
                  (oldAttrs.postInstall or "")
                  # bash
                  + ''
                    mkdir -p $out/share/bash-completion/completions
                    echo 'complete -F _comp_cmd_man batman' > $out/share/bash-completion/completions/batman

                    mkdir -p $out/share/fish/vendor_completions.d
                    echo 'complete batman --wraps man' > $out/share/fish/vendor_completions.d/batman.fish
                  '';
              }))
            ];
          };
        };
      };
    };
}
