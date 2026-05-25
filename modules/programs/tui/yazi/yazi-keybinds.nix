{
  m.yazi =
    { pkgs, config, ... }:
    {
      forte.yazi = {
        keymap = {
          mgr.prepend_keymap = with config.forte.lib; [
            (mkKeymap [ "i" "c" ]
              ''shell --block -- ${pkgs.mcat}/bin/mcat ls "$PWD" --hyprlink --kitty --ls-opts 'height=10%,items_per_row=6'; echo -e "\nPress Enter to return to Yazi..."; read ''
              "mcat preview of cwd"
            )
            (mkKeymap [ "l" "g" ] "plugin lazygit" "run lazygit")
            (mkKeymap [ "g" "r" ] ''shell -- ya emit cd "$(git rev-parse --show-toplevel)"'' "git root")
            (mkKeymap [ "g" "s" ] "shell -- ya emit cd /mnt/s3" "Go to S3")
          ];
        };
      };
    };
}
