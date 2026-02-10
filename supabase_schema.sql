-- Create the announcements table
create table announcements (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  name text not null,
  train_number text,
  platform int,
  status text, -- 'On Time', 'Delayed', 'Arrived'
  type text,   -- 'arrival', 'departure', 'emergency'
  speech_recognized text,
  "isPWD" boolean default false,
  time text,
  ticket jsonb,
  priority text default 'Low' -- 'High', 'Medium', 'Low'
);

-- Turn on Row Level Security
alter table announcements enable row level security;

-- Allow anyone to read announcements checks
create policy "Allow public read access"
  on announcements
  for select
  to public
  using (true);

-- Insert some dummy data
insert into announcements (name, train_number, platform, status, type, speech_recognized, "isPWD", time, priority)
values
  ('Rapit Transit', '12601', 1, 'On Time', 'arrival', 'Attention please, Train 12601 Mangalore Mail is arriving on platform 1', false, now(), 'Medium'),
  ('Express Line', '22638', 3, 'Delayed', 'arrival', 'Train 22638 West Coast Express is delayed by 15 minutes', true, now(), 'High'),
  ('Local Train', '06001', 2, 'On Time', 'departure', 'Local train to Tambaram leaving from platform 2', false, now(), 'Low');

-- Create the user profiles table
-- This table stores user profile information and makes it visible in Supabase admin
create table if not exists user_profiles (
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
