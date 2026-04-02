-- Fix for Announcement Upload and Realtime Display

-- 1. Allow authenticated users to insert announcements
-- This is needed for the voice input feature to work
create policy "Allow authenticated insert access"
  on announcements
  for insert
  to authenticated
  with check (true);

-- 2. Ensure Realtime is enabled for the announcements table
-- If it's already added, this might throw a "already exists" warning, which is fine.
alter publication supabase_realtime add table announcements;

-- 3. Verify RLS is enabled (it should be, but let's be sure)
alter table announcements enable row level security;
