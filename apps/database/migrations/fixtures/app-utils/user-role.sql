create or replace function app_utils.user_role(email text, pass text) returns name
  language plpgsql
  as $$
begin
  return (
  select role from :PRIVATE_SCHEMA.users
   where users.email = user_role.email
     and users.pass = crypt(user_role.pass, users.pass)
  );
end;
$$;
