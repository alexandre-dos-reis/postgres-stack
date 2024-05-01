{ pkgs, lib, config, inputs, ... }: let 

  APP_ENV_DEV = "development";
  APP_ENV_PROD = "production";
  APP_ENV_CI = "ci";
  APP_ENV_TEST = "test";

  APP_ANON_ROLE = "anon";
  APP_PERSON_ROLE = "person";

  APP_PRIVATE_SCHEMA = "app_private";
  APP_FRONT_SCHEMA = "app_front";
  APP_ADMIN_SCHEMA = "app_admin";

  # Postgres Database
  DB_DATABASE = "mydb";
  DB_PORT = 9876;
  DB_OWNER_USER = "alexandre";
  DB_OWNER_PASS = "alexandre";

  # Postgrest api
  PGRST_PORT = 3333;
  PGRST_DB_ANON_ROLE = "alexandre";

  # OpenApi
  OPENAPI_UI_PORT = 3434;
  OPENAPI_API_PORT = PGRST_PORT;
  in {
  env = {
    APP_ENV = APP_ENV_DEV;
  };

  # https://devenv.sh/packages/
  packages = with pkgs; [
    bun
    postgrest
    watchexec
  ];

  scripts = {
    # Graphile Migrate
    gm.exec = ''
      cd apps/database && \
        DATABASE_URL="postgres://${DB_OWNER_USER}:${DB_OWNER_PASS}@localhost:${toString DB_PORT}/${DB_DATABASE}" \
        SHADOW_DATABASE_URL="postgres://${DB_OWNER_USER}:${DB_OWNER_PASS}@localhost:${toString DB_PORT}/${DB_DATABASE}_shadow" \
        ROOT_DATABASE_URL="postgres://${DB_OWNER_USER}:${DB_OWNER_PASS}@localhost:${toString DB_PORT}/postgres" \
        ANON_ROLE=${APP_ANON_ROLE} \
        PERSON_ROLE=${APP_PERSON_ROLE} \
        PRIVATE_SCHEMA=${APP_PRIVATE_SCHEMA} \
        FRONT_SCHEMA=${APP_FRONT_SCHEMA} \
        ADMIN_SCHEMA=${APP_ADMIN_SCHEMA} \
        ${pkgs.bun}/bin/bunx --bunx graphile-migrate@next $1
    '';
  };

  processes = {
    postgrest.exec = ''
      PGRST_DB_URI="postgres://${DB_OWNER_USER}:${DB_OWNER_PASS}@localhost:${toString DB_PORT}/${DB_DATABASE}" \
        PGRST_SERVER_PORT="${toString PGRST_PORT}" \
        PGRST_OPEN_API_MODE="ignore-privileges" \
        PGRST_DB_ANON_ROLE="${PGRST_DB_ANON_ROLE}" \
        PGRST_DB_SCHEMAS="" \
        postgrest
    '';

    openapi-ui.exec = ''
      cd apps/openapi-ui && \
        VITE_OPENAPI_API_PORT=${toString PGRST_PORT} \
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
