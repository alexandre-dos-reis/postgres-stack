{ pkgs, lib, config, inputs, ... }: let 
  # https://devenv.sh

  # Roles
  APP_ANON_ROLE = "anon";
  APP_PERSON_ROLE = "person";
  APP_AUTH_ROLE = "auth";
  APP_AUTH_PASS = "auth";

  # One internal for all table 
  APP_PRIVATE_SCHEMA = "app_private";
  # One external for login, etc...
  APP_PUBLIC_SCHEMA = "app_public";
  # One per app.
  APP_FRONT_SCHEMA = "app_front";
  APP_ADMIN_SCHEMA = "app_admin";

  # Postgres Database
  DB_DATABASE = "mydb";
  DB_DATABASE_SHADOW = "${DB_DATABASE}_shadow";
  DB_PORT = 9876;
  DB_OWNER_USER = "alexandre";
  DB_OWNER_PASS = "alexandre";

  # Postgrest api
  PGRST_PORT = 3333;
  PGRST_DB_ANON_ROLE = APP_ANON_ROLE;
  PGRST_JWT_SECRET = "Q7uIlar1k1NY9Uz68SCM6gIOFrJIWgXM";
  PGRST_APP_SETTINGS_JWT_SECRET = "reallyreallyreallyreallyverysafe";

  # OpenApi UI
  OPENAPI_UI_PORT = 3434;
  OPENAPI_API_PORT = PGRST_PORT;

  in {
  env = {
    APP_ENV = "development";
  };

  # https://devenv.sh/packages/
  packages = with pkgs; [
    bun
    postgrest
    watchexec
    cowsay
    lolcat
  ];


  enterShell = ''
    echo "Welcome to the Postgres Stack !" | ${pkgs.cowsay}/bin/cowsay | ${pkgs.lolcat}/bin/lolcat
  '';

  scripts = {
    # Graphile Migrate
    # https://github.com/graphile/migrate
    gm.exec = ''
      cd apps/database && \
      DATABASE_URL="postgres://${DB_OWNER_USER}:${DB_OWNER_PASS}@localhost:${toString DB_PORT}/${DB_DATABASE}" \
      SHADOW_DATABASE_URL="postgres://${DB_OWNER_USER}:${DB_OWNER_PASS}@localhost:${toString DB_PORT}/${DB_DATABASE}_shadow" \
      ROOT_DATABASE_URL="postgres://${DB_OWNER_USER}:${DB_OWNER_PASS}@localhost:${toString DB_PORT}/postgres" \
      ANON_ROLE=${APP_ANON_ROLE} \
      PERSON_ROLE=${APP_PERSON_ROLE} \
      PRIVATE_SCHEMA=${APP_PRIVATE_SCHEMA} \
      PUBLIC_SCHEMA=${APP_PUBLIC_SCHEMA} \
      FRONT_SCHEMA=${APP_FRONT_SCHEMA} \
      ADMIN_SCHEMA=${APP_ADMIN_SCHEMA} \
      ${pkgs.bun}/bin/bunx --bunx graphile-migrate@next $1
    '';

    db-init.exec = ''
      for file in ./apps/database/init/*; do
        POSTGRES_USER="${DB_OWNER_USER}" \
        POSTGRES_PASS="${DB_OWNER_PASS}" \
        POSTGRES_DB="${DB_DATABASE}" \
        DB_DATABASE_SHADOW="${DB_DATABASE_SHADOW}" \
        AUTH_ROLE="${APP_AUTH_ROLE}" \
        AUTH_PASS="${APP_AUTH_PASS}" \
        ANON_ROLE="${APP_ANON_ROLE}" \
        PERSON_ROLE="${APP_PERSON_ROLE}" \
        bash $file
      done

    '';
  };

  processes = {
    # Postgrest
    # https://postgrest.org/en/v12/references/api/schemas.html#schemas
    # https://postgrest.org/en/v12/references/configuration.html
    # https://postgrest.org/en/v12/references/configuration.html#openapi-mode
    postgrest.exec = ''
      PGRST_LOG_LEVEL="info" \
      PGRST_DB_URI="postgres://${APP_AUTH_ROLE}:${APP_AUTH_PASS}@localhost:${toString DB_PORT}/${DB_DATABASE}" \
      PGRST_SERVER_PORT="${toString PGRST_PORT}" \
      PGRST_DB_ANON_ROLE="${PGRST_DB_ANON_ROLE}" \
      PGRST_DB_SCHEMAS="${APP_PUBLIC_SCHEMA}, ${APP_ADMIN_SCHEMA}, ${APP_FRONT_SCHEMA}" \
      PGRST_JWT_SECRET=${PGRST_JWT_SECRET} \
      PGRST_APP_SETTINGS_JWT_SECRET=${PGRST_APP_SETTINGS_JWT_SECRET} \
      PGRST_OPENAPI_MODE="ignore-privileges" \
      PGRST_OPENAPI_SECURITY_ACTIVE=true \
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


  services.postgres = {
    enable = true;
    package = pkgs.postgresql_16;
    listen_addresses = "127.0.0.1";
    port = DB_PORT;
    extensions = ext: [
      ext.pgjwt
    ];
    initialDatabases = [
      { name = DB_DATABASE; }
    ];
    initialScript = ''
      create role ${DB_OWNER_USER} with login password '${DB_OWNER_PASS}' superuser;
	    grant connect on database postgres to ${DB_OWNER_USER};
	    grant all on database ${DB_DATABASE} to ${DB_OWNER_USER};
    '';
  };
}
