module.exports = {
  pgSettings: {
    // "search_path": "app_public,app_private,app_hidden,public",
  },
  placeholders: {
    ":ANON_ROLE": "!ENV",
    ":PERSON_ROLE": "!ENV",
    ":PRIVATE_SCHEMA": "!ENV",
    ":PUBLIC_SCHEMA": "!ENV",
    ":FRONT_SCHEMA": "!ENV",
    ":ADMIN_SCHEMA": "!ENV",
  },
  afterReset: [
    // "afterReset.sql",
    // { "_": "command", "command": "graphile-worker --schema-only" },
  ],
  afterAllMigrations: [
    // {
    //   "_": "command",
    //   "shadow": true,
    //   "command": "if [ \"$IN_TESTS\" != \"1\" ]; then ./scripts/dump-db; fi",
    // },
  ],

  afterCurrent: [
    // {
    //   "_": "command",
    //   "shadow": true,
    //   "command": "if [ \"$IN_TESTS\" = \"1\" ]; then ./scripts/test-seed; fi",
    // },
  ],

  /****************************************************************************\
  ***                                                                        ***
  ***         You probably don't want to edit anything below here.           ***
  ***                                                                        ***
  \****************************************************************************/

  /*
   * manageGraphileMigrateSchema: if you set this false, you must be sure to
   * keep the graphile_migrate schema up to date yourself. We recommend you
   * leave it at its default.
   */
  // "manageGraphileMigrateSchema": true,

  /*
   * migrationsFolder: path to the folder in which to store your migrations.
   */
  // migrationsFolder: "./migrations",

  "//generatedWith": "2.0.0-rc.2",
};
