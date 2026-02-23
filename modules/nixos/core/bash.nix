{
  flake.nixosModules.core =
    { config, ... }:
    {
      programs.bash = {
        enable = true;
        shellInit = ''
          export NOCTALIA_AP_GOOGLE_API_KEY="$(cat ${config.sops.secrets.gemini.path})"
        '';
      };
    };
}
