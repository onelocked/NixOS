{
  flake.modules.nixos.default =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      programs.bash = {
        enable = true;
        interactiveShellInit =
          lib.mkIf config.programs.fish.enable or false # bash
            ''
              if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
              then
                shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
                exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
              fi
            '';
      };
    };
}
