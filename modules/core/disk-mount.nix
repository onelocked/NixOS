{
  exo.core =
    { pkgs, ... }:
    {
      services = {
        devmon.enable = false;
        gvfs.enable = true;
        # udisks2.enable = false;
      };
      hj.packages = with pkgs; [ glib ];
    };
}
