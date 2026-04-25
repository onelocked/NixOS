{
  description = "onelock's dendritic nixos flake configuration";

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports =
        with inputs.nixpkgs.lib;
        ./modules
        |> fileset.fileFilter (file: file.hasExt "nix" && !hasPrefix "_" file.name)
        |> fileset.toList;
    };

  inputs = {
    nixpkgs.follows = "extra-modules/nixpkgs";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-file.url = "github:vic/flake-file";
    wrappers = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    extra-modules = {
      url = "github:onelocked/extra-modules";
      inputs = {
        flake-parts.follows = "flake-parts";
        import-tree.follows = "import-tree";
        systems.follows = "systems";
      };
    };
    flake-compat.url = "github:NixOS/flake-compat";
    fuzzy-search-yazi = {
      url = "github:onelocked/fuzzy-search.yazi/dev";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };
    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
      inputs = {
        flake-parts.follows = "flake-parts";
        flake-compat.follows = "flake-compat";
      };
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };
    systems.url = "github:nix-systems/x86_64-linux";
    vicinae-extensions = {
      url = "github:vicinaehq/extensions";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
        systems.follows = "systems";
        vicinae.follows = "extra-modules/vicinae";
      };
    };
    vimmax = {
      url = "github:onelocked/vimmax";
      inputs = {
        flake-parts.follows = "flake-parts";
        import-tree.follows = "import-tree";
        systems.follows = "systems";
      };
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-theme-store = {
      url = "github:zen-browser/theme-store";
      flake = false;
    };
  };
}
