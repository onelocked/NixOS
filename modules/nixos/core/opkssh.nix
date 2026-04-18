{ self, ... }:
let
  inherit (self.variables) username homedir;
in
{
  m.opkssh =
    { pkgs, config, ... }:
    {
      environment.systemPackages = [ pkgs.opkssh ];
      sops = {
        secrets.client_id = {
          owner = username;
          key = "client_id";
          format = "yaml";
          sopsFile = config.sops.defaultSopsFile;
        };
        secrets.pocket_id_issuer = {
          key = "pocket_id_issuer";
          owner = username;
          format = "yaml";
          sopsFile = config.sops.defaultSopsFile;
        };
        templates."opkssh-config.yml" = {
          content = # yaml
            ''
              ---
              default_provider: PocketID

              providers:
                - alias: PocketID
                  issuer: ${config.sops.placeholder.pocket_id_issuer}
                  client_id: ${config.sops.placeholder.client_id}
                  scopes: openid email profile
                  access_type: offline
                  use_pkce: true
                  prompt: consent
                  redirect_uris:
                    - http://localhost:3000/login-callback
                    - http://localhost:10001/login-callback
                    - http://localhost:11110/login-callback
            '';
          path = homedir + "/.opk/config.yml";
          owner = username;
        };
      };
    };
}
