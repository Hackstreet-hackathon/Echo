-- Table to store user's saved announcements
create table if not exists saved_announcements (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users on delete cascade not null,
  announcement_id uuid references announcements on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  -- Ensure a user can only save the same announcement once
  unique(user_id, announcement_id)
);

-- Turn on Row Level Security
alter table saved_announcements enable row level security;

-- Users can view their own saved announcements
create policy "Users can view own saved announcements"
  on saved_announcements
  for select
  using (auth.uid() = user_id);

-- Users can save announcements for themselves
create policy "Users can insert own saved announcements"
  on saved_announcements
  for insert
  with check (auth.uid() = user_id);

-- Users can unsave announcements for themselves
create policy "Users can delete own saved announcements"
  on saved_announcements
  for delete
  using (auth.uid() = user_id);
