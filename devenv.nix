{ pkgs, lib, config, inputs, ... }:
let 
  DB_DATABASE = "mydb";
  DB_PORT = 9876;
  DB_OWNER_USER = "alexandre";
  DB_OWNER_PASS = "alexandre";

  PGRST_PORT = 3333;

in {
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = with pkgs; [ 
    nodejs_18
    postgrest
  ];

  processes = {
    postgrest.exec = ''
      PGRST_DB_URI="postgres://${DB_OWNER_USER}:${DB_OWNER_PASS}@localhost:${toString DB_PORT}/${DB_DATABASE}" \
      PGRST_SERVER_PORT="${toString PGRST_PORT}" \
        postgrest
    '';

  };

  # https://devenv.sh/scripts/
  scripts.hello.exec = "echo hello from $GREET";

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
      # settings = {};
  };


}
