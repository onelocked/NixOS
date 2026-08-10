{
  perSystem =
    { pkgs, self', ... }:
    {
      devShells.remote-install = pkgs.mkShell { packages = [ self'.legacyPackages.remote-install ]; };
      legacyPackages.remote-install = pkgs.writeShellApplication {
        name = "remote-install";
        runtimeInputs = with pkgs; [
          gum
          jq
          openssh
          coreutils
        ];

        text = ''
          # --- helpers ---
          WORK_DIR=$(mktemp -d)
          trap 'rm -rf "$WORK_DIR"' EXIT
          unset SSH_AUTH_SOCK

          die() {
            gum style --foreground 196 "Error: $1"
            exit 1
          }

          select_host() {
            echo "Parsing flake for NixOS configurations..." >&2
            local hosts
            hosts=$(nix eval .#nixosConfigurations --apply builtins.attrNames --json \
              --extra-experimental-features "nix-command flakes" | jq -r '.[]' || true)

            if [ -z "$hosts" ]; then
              gum style --foreground 214 "Warning: Could not automatically detect configurations." >&2
              echo "Enter the flake host (e.g., gaming-pc):" >&2
              gum input --placeholder "gaming-pc"
            else
              echo "Select the target NixOS configuration:" >&2
              echo "$hosts" | gum choose
            fi
          }

          # --- banner ---
          clear
          gum style \
            --foreground 212 --border-foreground 212 --border double \
            --align center --width 50 --margin "1 2" --padding "1 2" \
            "NixOS Anywhere Deployer"

          # --- target connection ---
          echo "Enter target connection string (e.g., root@192.168.1.100):"
          TARGET_IP=$(gum input --placeholder "root@192.168.1.100" --value "root@")
          if [ -z "$TARGET_IP" ] || [ "$TARGET_IP" = "root@" ]; then
            die "Target IP is required."
          fi

          SSH_PORT=$(gum input --placeholder "22" --value "22" --header "Enter SSH port:")
          SSH_PORT="''${SSH_PORT:-22}"

          # --- hardware configuration ---
          echo "Hardware Configuration Options:"
          HW_OPTION=$(gum choose \
            "Skip (Continue to install)" \
            "Fetch via kexec (For non-NixOS targets)" \
            "Fetch directly via SSH (For NixOS targets)")

          if [ "$HW_OPTION" != "Skip (Continue to install)" ]; then
            if [ "$HW_OPTION" = "Fetch via kexec (For non-NixOS targets)" ]; then
              HOST=$(select_host)
              if [ -z "$HOST" ]; then
                die "Flake host is required."
              fi

              TMP_CONFIG="$WORK_DIR/hardware-configuration.nix"

              gum style --foreground 82 "Fetching hardware configuration from $TARGET_IP via kexec..."
              echo

              nix run github:nix-community/nixos-anywhere -- \
                --ssh-option "Port=$SSH_PORT" \
                --flake .#"$HOST" \
                --phases kexec \
                --generate-hardware-config nixos-generate-config "$TMP_CONFIG" \
                "$TARGET_IP"

              if [ ! -s "$TMP_CONFIG" ]; then
                die "Failed to fetch configuration."
              fi

              RAW_CONFIG=$(cat "$TMP_CONFIG")
            else
              gum style --foreground 82 "Fetching hardware configuration from $TARGET_IP via SSH..."
              echo

              RAW_CONFIG=$(ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=yes -p "$SSH_PORT" -T "$TARGET_IP" \
                "nixos-generate-config --no-filesystems --show-hardware-config")

              if [ -z "$RAW_CONFIG" ]; then
                die "Failed to fetch configuration."
              fi
            fi

            OUT_FILE="./hardware-configuration.nix"
            echo "$RAW_CONFIG" > "$OUT_FILE"

            gum style --margin "1 0" --foreground 82 "Successfully saved to $OUT_FILE"
            cat "$OUT_FILE"
            echo

            echo "Hardware configuration saved. Please integrate it into your NixOS configuration, add to git, and run this script again."
            exit 0
          fi

          # --- host selection ---
          HOST=$(select_host)
          if [ -z "$HOST" ]; then
            die "Flake host is required."
          fi

          # --- deployment phases ---
          echo "Select execution phases (Space to toggle, Enter to confirm):"
          PHASES_RAW=$(gum choose --no-limit --selected "kexec,disko,install,reboot" "kexec" "disko" "install" "reboot")
          if [ -z "$PHASES_RAW" ]; then
            die "At least one phase must be selected."
          fi
          PHASES=$(echo "$PHASES_RAW" | paste -sd ',')

          # --- build location ---
          echo "Select which system to use for building:"
          BUILD_ON=$(gum choose "local" "remote")

          # --- confirmation ---
          gum style --margin "1 0" --foreground 82 "Configuration complete!"
          echo "Target: $TARGET_IP (port $SSH_PORT)"
          echo "Phases: $PHASES"
          echo "Host:   $HOST"
          echo "Build:  $BUILD_ON"
          echo

          if ! gum confirm "Ready to deploy?"; then
            echo "Aborting."
            exit 0
          fi

          # --- stage sops age key ---
          echo "Staging age key..."
          SOPS_AGE_DIR="$HOME/.config/sops/age"
          STAGING_DIR="$WORK_DIR/staging"

          echo "Select the age key to deploy:"
          SELECTED_KEY=$(find "$SOPS_AGE_DIR" -maxdepth 1 -type f -printf '%f\n' | gum choose)
          if [ -z "$SELECTED_KEY" ]; then
            die "No key selected."
          fi
          SELECTED_KEY="$SOPS_AGE_DIR/$SELECTED_KEY"

          TARGET_DIR="$STAGING_DIR/persist$SOPS_AGE_DIR"
          mkdir -p "$TARGET_DIR"
          cp "$SELECTED_KEY" "$TARGET_DIR/keys.txt"
          chmod 600 "$TARGET_DIR/keys.txt"

          # --- deploy ---
          echo "Running nixos-anywhere..."
          nix run github:nix-community/nixos-anywhere -- \
            --ssh-option "Port=$SSH_PORT" \
            --phases "$PHASES" \
            --extra-files "$STAGING_DIR" \
            --chown "/persist$SOPS_AGE_DIR/keys.txt" 1000:100 \
            --build-on "$BUILD_ON" \
            --flake .#"$HOST" \
            "$TARGET_IP"
        '';
      };
    };
  exo.configurations = {
    vm-empty = {
      bare = true;
      system = "x86_64-linux";
      modules = [
        {
          boot.loader.grub.device = "/dev/vda";
          fileSystems."/" = {
            device = "/dev/vda1";
            fsType = "ext4";
          };

          virtualisation.vmVariant = {
            virtualisation.memorySize = 4096;
            virtualisation.cores = 2;

            virtualisation.forwardPorts = [
              {
                from = "host";
                host.port = 2222;
                guest.port = 22;
              }
            ];

            virtualisation.diskSize = 20480;
          };

          services.openssh.enable = true;
          services.openssh.settings.PermitRootLogin = "yes";
          users.users.root.password = "nixos";

          system.stateVersion = "25.11";
        }
      ];
    };
    vm-deploy-test = {
      user = "onelock";
      hardware = "vm-deploy-test";
      server = true;
      theme = "light";
      extraConfig =
        { pkgs, ... }:
        {
          sops.defaultSopsFile = ../../.secrets/vps.yaml;
          boot.kernelPackages = pkgs.linuxPackages_latest;
        };
    };
  };
  exo.hardware.vm-deploy-test =
    { modulesPath, ... }:
    {
      imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

      boot.initrd.availableKernelModules = [
        "ata_piix"
        "uhci_hcd"
        "virtio_pci"
        "floppy"
        "sr_mod"
        "virtio_blk"
      ];
      boot.kernelModules = [ "kvm-amd" ];
      boot.kernel.sysctl = {
        "vm.swappiness" = 1;
      };

      disko.devices.nodev = {
        "/" = {
          fsType = "tmpfs";
          mountOptions = [
            "size=25%"
            "mode=755"
          ];
        };
      };

      disko.devices.disk.nixos = {
        device = "/dev/vda";
        type = "disk";
        content.type = "gpt";

        content.partitions.boot = {
          name = "boot";
          size = "1M";
          type = "EF02";
        };

        content.partitions.esp = {
          name = "ESP";
          size = "500M";
          type = "EF00";

          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };

        content.partitions.root = {
          name = "root";
          size = "100%";

          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];

            subvolumes = {
              "@persist" = {
                mountpoint = "/persist";
                mountOptions = [
                  "noatime"
                  "compress=zstd"
                ];
              };

              "@nix" = {
                mountpoint = "/nix";
                mountOptions = [
                  "noatime"
                  "compress=zstd"
                ];
              };

              "@swap" = {
                mountpoint = "/.swapvol";
                mountOptions = [ "noatime" ];
                swap = {
                  swapfile.size = "4G";
                };
              };
            };
          };
        };
      };
    };
}
