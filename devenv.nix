{ pkgs, lib, config, inputs, ... }: let 
  DB_DATABASE = "mydb";
  DB_PORT = 9876;
  DB_OWNER_USER = "alexandre";
  DB_OWNER_PASS = "alexandre";

  PGRST_PORT = 3333;
  PGRST_DB_ANON_ROLE = "alexandre";

  OPENAPI_API_PORT = PGRST_PORT;
  OPENAPI_UI_PORT = 3434;

  in {
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = with pkgs; [
    bun
    postgrest
    watchexec
  ];

  processes = {
    postgrest.exec = ''
      PGRST_DB_URI="postgres://${DB_OWNER_USER}:${DB_OWNER_PASS}@localhost:${toString DB_PORT}/${DB_DATABASE}" \
      PGRST_SERVER_PORT="${toString PGRST_PORT}" \
      PGRST_DB_ANON_ROLE="${PGRST_DB_ANON_ROLE}" \
      PGRST_OPEN_API_MODE="ignore-privileges" \
        postgrest
    '';

    openapi-ui.exec = ''
      cd apps/openapi-ui && \
      VITE_OPENAPI_API_PORT=${toString OPENAPI_API_PORT} \
        ${pkgs.bun}/bin/bun run dev --port ${toString OPENAPI_UI_PORT}
    '';

    openapi-codegen.exec = ''
      cd packages/openapi-codegen && \
        ${pkgs.watchexec}/bin/watchexec -- \
          ${pkgs.bun}/bin/bunx --bunx @hey-api/openapi-ts \
          -i http://localhost:${toString PGRST_PORT} \
          -o src
    '';
  };

  enterShell = ''
    hello
    git --version
  '';

  services.postgres = {
    enable = true;
    package = pkgs.postgresql_16;
    listen_addresses = "127.0.0.1";
    port = DB_PORT;
    initialDatabases = [
      { name = DB_DATABASE; }
    ];
    initialScript = ''
      drop role if exists ${DB_OWNER_USER};
      create role ${DB_OWNER_USER} with login password '${DB_OWNER_PASS}' superuser;
    '';
  };
}
