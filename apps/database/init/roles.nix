{
  DB_OWNER_USER, 
  DB_OWNER_PASS, 
  DB_DATABASE,
  AUTHENTICATOR_ROLE, 
  AUTHENTICATOR_PASS, 
  ANON_ROLE, 
  PERSON_ROLE
}: 
''
  drop role if exists ${DB_OWNER_USER};
  create role ${DB_OWNER_USER} with login password '${DB_OWNER_PASS}' superuser;
  grant connect on database postgres to ${DB_OWNER_USER};
  grant all on database ${DB_DATABASE} to ${DB_OWNER_USER};

  drop role if exists ${AUTHENTICATOR_ROLE};
  create role ${AUTHENTICATOR_ROLE} with login password '${AUTHENTICATOR_PASS}' noinherit;

  drop role if exists ${ANON_ROLE};
  create role ${ANON_ROLE} nologin;
  grant ${ANON_ROLE} to ${AUTHENTICATOR_ROLE};

  drop role if exists ${PERSON_ROLE};
  create role ${PERSON_ROLE} nologin;
  grant ${PERSON_ROLE} to ${AUTHENTICATOR_ROLE};
''
