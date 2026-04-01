{ inputs, ... }:
{
  flake.modules.homeManager.neovim = {
    imports = [ inputs.extra-modules.inputs.vimmax.homeManagerModules.default ];
    programs.vimmax = {
      enable = true;
      defaultEditor = true;
    };
  };
}
