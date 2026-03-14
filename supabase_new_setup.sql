-- Create the announcements table based on the new design
create table if not exists announcements (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  name text not null,
  speech_recognized text,
  "isPWD" boolean default false,
  time text,
  platform int4,
  ticket jsonb,
  priority text default 'Low', -- 'High', 'Medium', 'Low'
  train_number text,
  status text, -- 'On Time', 'Delayed', 'Arrived', 'Cancelled'
  type text,   -- 'arrival', 'departure', 'emergency'
  phone text
);

-- Turn on Row Level Security for announcements
alter table announcements enable row level security;

-- Allow public read access to announcements
create policy "Allow public read access"
  on announcements
  for select
  to public
  using (true);

-- Create the user profiles table based on the new design
create table if not exists user_profiles (
  id uuid references auth.users on delete cascade primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  phone text,
  display_name text,
  is_pwd boolean default false,
  disability_details text,
  preferred_train_no text,
  preferred_platform int4,
  ticket jsonb
);

-- Turn on Row Level Security for user_profiles
alter table user_profiles enable row level security;

-- Allow users to read their own profile
create policy "Users can view own profile"
  on user_profiles
  for select
  using (auth.uid() = id);

-- Allow users to insert their own profile
create policy "Users can insert own profile"
  on user_profiles
  for insert
  with check (auth.uid() = id);

-- Allow users to update their own profile
create policy "Users can update own profile"
  on user_profiles
  for update
  using (auth.uid() = id);

-- Create a function to handle new user profile creation
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.user_profiles (id, phone, display_name, is_pwd, disability_details)
  values (
    new.id,
    new.phone,
    new.raw_user_meta_data->>'display_name',
    coalesce((new.raw_user_meta_data->>'isPWD')::boolean, false),
    new.raw_user_meta_data->>'disability_details'
  );
  return new;
end;
$$ language plpgsql security definer;

-- Create a trigger to automatically create profile on user signup
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
