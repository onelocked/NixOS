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
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-file.url = "github:vic/flake-file";
    wrappers = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat.url = "github:NixOS/flake-compat";
    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lan-mouse = {
      url = "github:feschber/lan-mouse";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
      };
    };
    niri = {
      url = "github:niri-wm/niri/b82d52705e1424cf47b26dd7b096832901c31f56";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
      };
    };
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
    qml-niri = {
      url = "github:imiric/qml-niri/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        quickshell.follows = "quickshell";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    quickshell = {
      url = "github:quickshell-mirror/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
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
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vicinae = {
      url = "github:vicinaehq/vicinae";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };
    vicinae-extensions = {
      url = "github:vicinaehq/extensions";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
        systems.follows = "systems";
        vicinae.follows = "vicinae";
      };
    };
    vimmax = {
      url = "github:onelocked/vimmax";
      inputs = {
        flake-parts.follows = "flake-parts";
        systems.follows = "systems";
      };
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake/e272c7d4a4e6c99fbc164f38ade789c8103f8c0f";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-theme-store = {
      url = "github:zen-browser/theme-store";
      flake = false;
    };
  };
}
