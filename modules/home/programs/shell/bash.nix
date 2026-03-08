{
  flake.modules.nixos.default =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      programs.nano.enable = lib.mkForce false;
      programs.bash = {
        enable = true;
        interactiveShellInit = ''
          if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
          then
            shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
            exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
          fi
        '';
        shellInit = ''
          export NOCTALIA_AP_GOOGLE_API_KEY="$(cat ${config.sops.secrets.gemini.path})"
        '';
      };
    };
}
