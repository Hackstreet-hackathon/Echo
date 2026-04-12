drop policy if exists "Allow authenticated insert access" on announcements;
drop policy if exists "Allow public insert access" on announcements;
create policy "Allow public insert access"
  on announcements
  for insert
  to public
  with check (true);

alter publication supabase_realtime add table announcements;

alter table announcements enable row level security;
