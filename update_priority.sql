-- 1. Add priority column if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'announcements' AND column_name = 'priority') THEN
        ALTER TABLE announcements ADD COLUMN priority text DEFAULT 'Low';
    END IF;
END $$;

-- 2. Add train_number column if it is missing
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'announcements' AND column_name = 'train_number') THEN
        ALTER TABLE announcements ADD COLUMN train_number text;
    END IF;
END $$;

-- 3. Add status column if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'announcements' AND column_name = 'status') THEN
        ALTER TABLE announcements ADD COLUMN status text;
    END IF;
END $$;

-- 4. Add type column if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'announcements' AND column_name = 'type') THEN
        ALTER TABLE announcements ADD COLUMN type text;
    END IF;
END $$;

-- 5. Add platform column if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'announcements' AND column_name = 'platform') THEN
        ALTER TABLE announcements ADD COLUMN platform int;
    END IF;
END $$;

-- 6. Update priority based on announcement characteristics
-- High priority: Delayed, Cancelled, Emergency announcements, or PWD-related
UPDATE announcements SET priority = 'High' 
WHERE (status IN ('Delayed', 'Cancelled') 
   OR type = 'emergency' 
   OR "isPWD" = true)
   AND priority IS NOT NULL;

-- Medium priority: Express trains, important arrivals/departures that are on time
UPDATE announcements SET priority = 'Medium' 
WHERE COALESCE(priority, 'Low') = 'Low' 
  AND train_number IS NOT NULL
  AND (train_number LIKE '%26%' OR train_number LIKE '%22%' OR train_number LIKE '%12%')
  AND COALESCE(status, '') = 'On Time';

-- Specific updates for existing data (only if those records exist)
UPDATE announcements SET priority = 'Medium' 
WHERE train_number = '12601' AND COALESCE(status, '') = 'On Time';

UPDATE announcements SET priority = 'High' 
WHERE train_number = '22638'; -- This one is delayed

-- 7. Insert sample data with all columns (optional - comment out if not needed)
INSERT INTO announcements (name, train_number, platform, status, type, speech_recognized, "isPWD", time, priority)
VALUES ('Local Train', '06001', 2, 'On Time', 'departure', 'Local train to Tambaram leaving from platform 2', false, now(), 'Low');
