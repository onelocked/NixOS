{ inputs, ... }:
{
  flake-file.inputs.vimmax = {
    url = "github:onelocked/vimmax";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-parts.follows = "flake-parts";
    inputs.import-tree.follows = "import-tree";
    inputs.systems.follows = "systems";
  };
  flake.modules.nixos.neovim =
    { pkgs, ... }:
    {
      hj = {
        packages = [ inputs.vimmax.packages.${pkgs.stdenv.hostPlatform.system}.default ];
      };
      environment.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
    };
}
