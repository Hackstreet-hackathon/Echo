--STANDALONE SETUP FOR PHONE AUTH PROFILES
--Run this in Supabase SQL Editor to ensure phone signups correctly create profiles

-- 1. Ensure user_profiles table exists
create table if not exists public.user_profiles (
  id uuid references auth.users on delete cascade primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  phone text,
  display_name text,
  is_pwd boolean default false,
  disability_details text,
  preferred_train_no text,
  preferred_platform int,
  ticket jsonb
);

-- 2. Enable RLS
alter table public.user_profiles enable row level security;

-- 3. Basic Policies
do $$ 
begin
    if not exists (select 1 from pg_policies where policyname = 'Users can view own profile') then
        create policy "Users can view own profile" on user_profiles for select using (auth.uid() = id);
    end if;
    if not exists (select 1 from pg_policies where policyname = 'Users can insert own profile') then
        create policy "Users can insert own profile" on user_profiles for insert with check (auth.uid() = id);
    end if;
    if not exists (select 1 from pg_policies where policyname = 'Users can update own profile') then
        create policy "Users can update own profile" on user_profiles for update using (auth.uid() = id);
    end if;
end $$;

-- 4. Improved Profile Sync Function
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.user_profiles (id, phone, display_name, is_pwd, disability_details)
  values (
    new.id,
    new.phone, -- This will capture the phone number from auth.users
    new.raw_user_meta_data->>'display_name',
    coalesce((new.raw_user_meta_data->>'isPWD')::boolean, false),
    new.raw_user_meta_data->>'disability_details'
  )
  on conflict (id) do update set
    phone = excluded.phone,
    display_name = coalesce(excluded.display_name, user_profiles.display_name),
    is_pwd = coalesce(excluded.is_pwd, user_profiles.is_pwd),
    disability_details = coalesce(excluded.disability_details, user_profiles.disability_details);
  return new;
end;
$$ language plpgsql security definer;

-- 5. Re-apply Trigger
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
