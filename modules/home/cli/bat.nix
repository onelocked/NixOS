{
  m.bat =
    { pkgs, wrappers, ... }:
    {
      hj.packages = [
        (wrappers.lib.wrapPackage {
          inherit pkgs;
          package = pkgs.bat;
          flags = {
            "--theme" = "TwoDark";
            "--style" = "plain";
          };
        })
        (pkgs.bat-extras.batman.overrideAttrs (o: {
          postInstall =
            (o.postInstall or "")
            # bash
            + ''
              mkdir -p $out/share/bash-completion/completions
              echo 'complete -F _comp_cmd_man batman' > $out/share/bash-completion/completions/batman

              mkdir -p $out/share/fish/vendor_completions.d
              echo 'complete batman --wraps man' > $out/share/fish/vendor_completions.d/batman.fish
            '';
        }))
      ];
      environment.shellAliases = {
        man = "batman --paging=auto";
      };
    };
}
