{
  m.yazi = {
    custom.programs.yazi = {
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
        ];
      };
    };
  };
}
