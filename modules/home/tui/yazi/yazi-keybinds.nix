{
  flake.modules.homeManager.yazi = {
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
              "b"
              "y"
            ];
            run = [
              ''shell -- for path in %s; do echo "file://$path"; done | wl-copy -t text/uri-list''
            ];
            desc = "copy to clipboard";
          }
        ];
      };
    };
  };
}
