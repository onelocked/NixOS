{ self, ... }:
{
  flake.modules.nixos.niri =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    lib.mkMerge [
      {
        programs.niri = {
          enable = true;
          useNautilus = false;
        };
        programs.xwayland = {
          enable = true;
          package = pkgs.xwayland-satellite;
        };
        xdg.portal = {
          config.niri = {
            "org.freedesktop.impl.portal.FileChooser" = lib.mkForce [
              "termfilechooser"
            ];
          };
        };
      }
      (lib.mkIf (config.programs.niri.enable) (
        let
          niri-command = "${lib.getExe' config.programs.niri.package "niri-session"}";
          inherit (self.variables) username;
        in
        {
          services = {
            displayManager.enable = lib.mkForce false;
            greetd = {
              enable = true;
              settings = {
                default_session = {
                  command = niri-command;
                  user = username;
                };
              };
            };
          };
          security.pam.services.greetd = {
            enableGnomeKeyring = true;
          };
        }
      ))
    ];

  flake.modules.homeManager.default =
    {
      pkgs,
      lib,
      config,
      osConfig,
      ...
    }:
    lib.mkIf (osConfig.programs.niri.enable) (
      let
        general =
          pkgs.writeText "general.kdl" # kdl
            ''
              prefer-no-csd

              clipboard {
                  disable-primary
              }

              output "HDMI-A-1" {
                  mode "3440x1440@99.982"
                  scale 1
                  transform "normal"
                  position x=0 y=0

              }

              overview {
                zoom 0.35
                workspace-shadow {
                  off
                }
              }

              layer-rule {
                match namespace="^noctalia-wallpaper*"
                place-within-backdrop true
              }

              layer-rule {
                match namespace="^fuzzel*"
                background-effect {
                  blur true
                  xray false
                }
              }

              hotkey-overlay {
                   skip-at-startup
              }

              screenshot-path "${config.xdg.userDirs.pictures}/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

              debug {
                // Allows notification actions and window activation from Noctalia.
                honor-xdg-activation-with-invalid-serial
              }

              recent-windows {
                  // off
                  debounce-ms 750
                  open-delay-ms 250
                  highlight {
                      active-color "#999999ff"
                      urgent-color "#ff9999ff"
                      padding 15
                      corner-radius 20
                  }
                  previews {
                      max-height 480
                      max-scale 0.5
                  }
              }
              // Ask for keyring password at startup
              spawn-sh-at-startup "${pkgs.libsecret}/bin/secret-tool lookup app keyring-init || echo 'init' | secret-tool store --label='keyring-init' app keyring-init"
            '';
        workspaces =
          pkgs.writeText "workspaces.kdl" # kdl
            ''
              workspace "social" {
                 layout {
                      center-focused-column "never"
                      preset-column-widths {
                      proportion  0.79
                      proportion 0.21
                  }
                 }

              }
              workspace "coding" {
                layout {
                     center-focused-column "never"
                      preset-column-widths {
                      proportion 0.5
                      fixed 2488
                  }
                    default-column-width { fixed 2488; }

                  }
                 }

              workspace "browser" {
                layout {
                     center-focused-column "never"
                      default-column-width { proportion 0.749; }
                      preset-column-widths {
                      proportion 0.749
                      fixed 2871
                  }
                  }
                 }

              workspace "media" {
                layout {
                     center-focused-column "never"
                      default-column-width { proportion 0.749;}
                      preset-column-widths {
                      proportion 0.749
                  }
                  }
                 }
            '';
        input =
          pkgs.writeText "input.kdl" # kdl
            ''
              input {
                  disable-power-key-handling
                  keyboard {
                      repeat-rate 40
                      repeat-delay 370
                      xkb {
                           layout "us,ru"
                           // options "grp:ctrl_space_toggle"
                      }
                      track-layout "global"
                  }
                  mouse {
                      accel-profile "flat"
                      natural-scroll
                      scroll-factor 1.2
                      scroll-method "on-button-down"
                      scroll-button 273
                      scroll-button-lock
                  }
              }

              cursor {
                  xcursor-theme "Bibata-Modern-Ice"
                  xcursor-size 24
              }

              gestures {
                  hot-corners {
                      off
                  }
              }
            '';
        layout =
          pkgs.writeText "layout.kdl" # kdl
            ''
              layout {
                  background-color "transparent"
                  always-center-single-column
                  gaps 9
                  center-focused-column "on-overflow"
                  // You can customize the widths that "switch-preset-column-width" (Mod+R) toggles between.
                  preset-column-widths {
                      fixed 2489
                      fixed 871
                  }
                  default-column-width { fixed 2489; }
                  focus-ring {
                      off
                      width 0.5
                  }

                  shadow {
                      on
                      draw-behind-window true
                      softness 50
                      spread 5
                      offset x=0 y=0
                      color "#000000"
                  }
              }
            '';
        animation =
          pkgs.writeText "animation.kdl" # kdl
            ''
              animations {
                  workspace-switch {
                      spring damping-ratio=0.92 stiffness=523 epsilon=0.0001
                  }
              window-open {
                      duration-ms 200
                      curve "ease-out-expo"
                      custom-shader "vec4 fall_from_top(vec3 coords_geo, vec3 size_geo) {
                          float progress = niri_clamped_progress * niri_clamped_progress;
                          vec2 coords = (coords_geo.xy - vec2(0.5, 0.0)) * size_geo.xy;
                          coords.y += (1.0 - progress) * 1440.0;
                          float random = (niri_random_seed - 0.5) / 2.0;
                          random = sign(random) - random;
                          float max_angle = 0.5 * random;
                          float angle = (1.0 - progress) * max_angle;
                          mat2 rotate = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
                          coords = rotate * coords;
                          coords_geo = vec3(coords / size_geo.xy + vec2(0.5, 0.0), 1.0);
                          vec3 coords_tex = niri_geo_to_tex * coords_geo;
                          return texture2D(niri_tex, coords_tex.st);
                      }
                      vec4 open_color(vec3 coords_geo, vec3 size_geo) {
                          return fall_from_top(coords_geo, size_geo);
                      }"
                  }
                  window-close {
                      duration-ms 200
                      curve "linear"
                      custom-shader "vec4 fall_and_rotate(vec3 coords_geo, vec3 size_geo) {
                          float progress = niri_clamped_progress * niri_clamped_progress;
                          vec2 coords = (coords_geo.xy - vec2(0.5, 1.0)) * size_geo.xy;
                          coords.y -= progress * 1440.0;
                          float random = (niri_random_seed - 0.5) / 2.0;
                          random = sign(random) - random;
                          float max_angle = 0.5 * random;
                          float angle = progress * max_angle;
                          mat2 rotate = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
                          coords = rotate * coords;
                          coords_geo = vec3(coords / size_geo.xy + vec2(0.5, 1.0), 1.0);
                          vec3 coords_tex = niri_geo_to_tex * coords_geo;
                          vec4 color = texture2D(niri_tex, coords_tex.st);
                          return color;
                      }
                      vec4 close_color(vec3 coords_geo, vec3 size_geo) {
                          return fall_and_rotate(coords_geo, size_geo);
                          "
                      }
                  }
            '';
      in
      {
        xdg.configFile."niri/config.kdl".text = # kdl
          ''
            include "${general}"
            include "${input}"
            include "${layout}"
            include "${workspaces}"
            include "${animation}"
            include "noctalia.kdl"
            include "keybinds.kdl"
            include "windowrules.kdl"
          '';
      }
    );
}
