{
  flake-file.inputs.vimmax = {
    url = "github:onelocked/vimmax";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-parts.follows = "flake-parts";
    inputs.import-tree.follows = "import-tree";
  };

  flake.modules.homeManager.neovim =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.neovim ];
    };
}
