-- Fix for Announcement Upload and Realtime Display

-- 1. Allow authenticated users to insert announcements
-- This is needed for the voice input feature to work
create policy "Allow authenticated insert access"
  on announcements
  for insert
  to authenticated
  with check (true);

-- 2. Ensure Realtime is enabled for the announcements table
-- This is needed for the app to show new announcements instantly
begin;
  -- Remove if already exists to avoid errors
  alter publication supabase_realtime drop table if exists announcements;
  -- Add the table to the publication
  alter publication supabase_realtime add table announcements;
commit;

-- 3. Verify RLS is enabled (it should be, but let's be sure)
alter table announcements enable row level security;
