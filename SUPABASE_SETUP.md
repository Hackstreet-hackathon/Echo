# Supabase Database Setup Instructions

## Apply the User Profiles Schema

To make disability information visible in your Supabase admin panel, you need to run the SQL schema from `supabase_schema.sql`.

### Steps:

1. **Open your Supabase Dashboard**
   - Go to https://supabase.com/dashboard
   - Select your project

2. **Navigate to SQL Editor**
   - Click on "SQL Editor" in the left sidebar
   - Click "New Query"

3. **Copy and paste the entire contents of `supabase_schema.sql`**
   - This will create:
     - `user_profiles` table with columns: `id`, `email`, `display_name`, `is_pwd`, `disability_details`, etc.
     - Row Level Security policies
     - Automatic trigger to sync user data from auth metadata to the profiles table

4. **Run the query**
   - Click "Run" or press Ctrl+Enter

5. **Verify the setup**
   - Go to "Table Editor" in the left sidebar
   - You should now see a `user_profiles` table
   - When users sign up, their profile data (including disability status and details) will automatically appear in this table

## Viewing User Disability Information

After running the schema:

1. Go to **Table Editor** → **user_profiles**
2. You'll see all user profiles with columns:
   - `display_name` - User's display name
   - `is_pwd` - Boolean indicating if user has a disability (true/false)
   - `disability_details` - Text description of the disability (only filled if `is_pwd` is true)
   - Other profile fields

This makes it easy to view and manage user disability information directly from the Supabase admin panel!
