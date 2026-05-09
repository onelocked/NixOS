{
  m.yazi =
    { pkgs, ... }:
    {
      forte.yazi = {
        keymap = {
          mgr.prepend_keymap = [
            {
              on = [
                "i"
                "c"
              ];
              run = ''shell --block -- ${pkgs.mcat}/bin/mcat ls "$PWD" --hyprlink --kitty --ls-opts 'height=10%,items_per_row=6'; echo -e "\nPress Enter to return to Yazi..."; read '';
              desc = "mcat preview of cwd";
            }
            {
              on = [
                "l"
                "g"
              ];
              run = "plugin lazygit";
              desc = "run lazygit";
            }
            {
              on = [
                "g"
                "r"
              ];
              run = ''shell -- ya emit cd "$(git rev-parse --show-toplevel)"'';
              desc = "git root";
            }
            {
              on = [
                "g"
                "s"
              ];
              run = "shell -- ya emit cd /mnt/s3";
              desc = "Go to S3";
            }
          ];
        };
      };
    };
}
