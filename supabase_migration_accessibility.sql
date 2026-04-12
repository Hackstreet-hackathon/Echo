-- Add accessibility_settings JSONB column to user_profiles
alter table user_profiles add column if not exists accessibility_settings jsonb default '{}'::jsonb;

-- Update handle_new_user to include empty settings
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.user_profiles (id, phone, display_name, is_pwd, disability_details, accessibility_settings)
  values (
    new.id,
    new.phone,
    new.raw_user_meta_data->>'display_name',
    coalesce((new.raw_user_meta_data->>'isPWD')::boolean, false),
    new.raw_user_meta_data->>'disability_details',
    '{}'::jsonb
  );
  return new;
end;
$$ language plpgsql security definer;
