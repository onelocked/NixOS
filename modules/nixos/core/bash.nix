{
  flake.modules.nixos.core = {
    programs.bash = {
      enable = true;
      interactiveShellInit = ''
        if ! [ "$TERM" = "dumb" ] && [ -z "$BASH_EXECUTION_STRING" ]; then
          exec nu
        fi
      '';
    };
  };
}
