{
  perSystem =
    { pkgs, self', ... }:
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          nix-tree
          nix-update
          nix-init
          nix-melt
          self'.legacyPackages.figlet
        ];
      };
      legacyPackages.figlet = pkgs.symlinkJoin {
        name = "figlet-custom";
        paths = [
          pkgs.figlet
          (pkgs.stdenvNoCC.mkDerivation {
            name = "figlet-fonts";
            src = pkgs.fetchzip {
              url = "https://github.com/xero/figlet-fonts/archive/refs/heads/main.zip";
              hash = "sha256-QogGNQ772bcYLOzgO0i6ydbzxjn5jnXNav72vW/SXm8=";
            };
            dontUnpack = true;
            dontBuild = true;
            dontConfigure = true;
            installPhase = ''
              mkdir -p $out/share/figlet
              cp -r $src/* $out/share/figlet/
            '';
          })
        ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/figlet \
            --set FIGLET_FONTDIR $out/share/figlet
        '';
      };
    };
}
