{
  exo.core =
    {
      pkgs,
      config,
      constants,
      ...
    }:
    let
      inherit (constants) username homedir;
    in
    {
      hj.packages = [ pkgs.opkssh ];
      sops = {
        secrets.client_id.owner = username;
        secrets.pocket_id_issuer.owner = username;
        templates."opkssh-config.yml" = {
          content = # yaml
            with config.sops.placeholder; ''
              ---
              default_provider: PocketID

              providers:
                - alias: PocketID
                  issuer: ${pocket_id_issuer}
                  client_id: ${client_id}
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
