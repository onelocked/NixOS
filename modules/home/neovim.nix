{ inputs, ... }:
{
  ff.vimmax = {
    url = "github:onelocked/vimmax";
    inputs = {
      flake-parts.follows = "flake-parts";
      systems.follows = "systems";
    };
  };
  m.neovim =
    { pkgs, ... }:
    {
      hj = {
        packages = [ inputs.vimmax.packages.${pkgs.stdenv.hostPlatform.system}.default ];
        environment.sessionVariables = {
          EDITOR = "nvim";
          VISUAL = "nvim";
        };
      };
    };
}
