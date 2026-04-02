-- Fix for Announcement Upload and Realtime Display

-- 1. Allow ALL users (anon and authenticated) to insert announcements
-- This ensures voice input works regardless of the specific auth token role
drop policy if exists "Allow authenticated insert access" on announcements;
drop policy if exists "Allow public insert access" on announcements;
create policy "Allow public insert access"
  on announcements
  for insert
  to public
  with check (true);

-- 2. Ensure Realtime is enabled for the announcements table
-- If it's already added, this might throw a "already exists" warning, which is fine.
alter publication supabase_realtime add table announcements;

-- 3. Verify RLS is enabled (it should be, but let's be sure)
alter table announcements enable row level security;
