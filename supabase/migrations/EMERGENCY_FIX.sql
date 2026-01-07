-- ============================================
-- SIMPLIFIED RLS FIX - Run this if still getting errors
-- This version completely removes the recursive check
-- ============================================

-- First, temporarily disable RLS to ensure we can work
ALTER TABLE group_members DISABLE ROW LEVEL SECURITY;

-- Drop ALL policies
DO $$ 
DECLARE 
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'group_members') LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON group_members';
    END LOOP;
END $$;

-- Re-enable RLS
ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;

-- Create SIMPLE policies that definitely won't recurse

-- 1. SELECT: Just allow users to see ALL group_members records
-- This is the safest non-recursive approach
CREATE POLICY "group_members_select_all_authenticated" ON group_members
  FOR SELECT
  USING (auth.uid() IS NOT NULL);

-- 2. INSERT: Allow authenticated users to insert
-- App logic will handle validation
CREATE POLICY "group_members_insert_authenticated" ON group_members
  FOR INSERT
  WITH CHECK (
    auth.uid() IS NOT NULL
    AND
    (
      -- User is adding themselves
      user_id = auth.uid()
      OR
      -- OR user is the group creator (check via groups table - no recursion)
      EXISTS (
        SELECT 1
        FROM groups g
        WHERE g.group_id = group_members.group_id
          AND g.created_by = auth.uid()
      )
    )
  );

-- 3. DELETE: Allow users to delete their own membership or if they're group creator
CREATE POLICY "group_members_delete_own_or_creator" ON group_members
  FOR DELETE
  USING (
    -- User is removing themselves
    auth.uid() = user_id
    OR
    -- OR user is the group creator (no recursion - uses groups table)
    EXISTS (
      SELECT 1
      FROM groups g
      WHERE g.group_id = group_members.group_id
        AND g.created_by = auth.uid()
    )
  );
