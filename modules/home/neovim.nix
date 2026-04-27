{
  ff.vimmax = {
    url = "github:onelocked/vimmax";
    inputs = {
      flake-parts.follows = "flake-parts";
      systems.follows = "systems";
    };
  };
  m.neovim =
    { inputs', ... }:
    {
      hj = {
        packages = [ inputs'.vimmax.packages.default ];
        environment.sessionVariables = {
          EDITOR = "nvim";
          VISUAL = "nvim";
        };
      };
    };
}
