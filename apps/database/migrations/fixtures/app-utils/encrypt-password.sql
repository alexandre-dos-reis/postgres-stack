create or replace function app_utils.encrypt_pass() returns trigger as $$
begin
  if tg_op = 'INSERT' or new.pass <> old.pass then
    new.pass = public.crypt(new.pass, public.gen_salt('bf'));
  end if;
  return new;
end
$$ language plpgsql;

