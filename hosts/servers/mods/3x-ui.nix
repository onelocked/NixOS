{
  exo.mods.three-x-ui = {
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    forte.persist.root.directories = [ "/var/lib/containers" ];

    virtualisation.oci-containers.backend = "podman";
    virtualisation.oci-containers.containers."3x-ui" = {
      image = "ghcr.io/mhsanaei/3x-ui:latest";
      autoStart = true;
      volumes = [ "/persist/home/onelock/Documents/3x-ui:/etc/x-ui" ];
      # no need to open firewalls, podman/docker aggressively punches holes in the firewall...
      ports = [
        "127.0.0.1:2053:2053"
        "443:443/tcp"
        "443:443/udp"
      ];
    };
  };
}
