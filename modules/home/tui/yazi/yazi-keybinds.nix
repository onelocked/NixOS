{
  flake.modules.homeManager.yazi =
    { pkgs, ... }:
    {
      programs.yazi = {
        keymap = {
          mgr.prepend_keymap = [
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
            {
              on = [
                "<C-y>"
              ];
              run = [
                ''shell -- for path in %s; do echo "file://$path"; done | ${pkgs.wl-clipboard-rs}/bin/wl-copy -t text/uri-list''
              ];
              desc = "copy to clipboard";
            }
          ];
        };
      };
    };
}
