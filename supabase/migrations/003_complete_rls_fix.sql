-- COMPLETE FIX for all RLS policies
-- Run this entire script in Supabase SQL Editor

-- ============================================
-- 1. FIX GROUP_MEMBERS POLICIES
-- ============================================
DROP POLICY IF EXISTS "Allow own memberships" ON group_members;
DROP POLICY IF EXISTS "Allow insert for authenticated" ON group_members;
DROP POLICY IF EXISTS "Users can view their own memberships" ON group_members;
DROP POLICY IF EXISTS "Users can insert their own memberships" ON group_members;
DROP POLICY IF EXISTS "Users can delete their own memberships" ON group_members;

-- Allow users to see ALL members in groups they belong to
CREATE POLICY "View members in my groups" ON group_members
  FOR SELECT USING (
    group_id IN (
      SELECT gm.group_id FROM group_members gm WHERE gm.user_id = auth.uid()
    )
  );

-- Allow inserting memberships (for adding members)
CREATE POLICY "Add members to groups" ON group_members
  FOR INSERT WITH CHECK (
    -- Either adding yourself
    user_id = auth.uid() OR
    -- Or you're an admin of the group
    EXISTS (
      SELECT 1 FROM group_members gm
      WHERE gm.group_id = group_members.group_id
      AND gm.user_id = auth.uid()
      AND gm.role = 'admin'
    )
  );

-- Allow removing memberships
CREATE POLICY "Remove members" ON group_members
  FOR DELETE USING (
    -- Either removing yourself
    user_id = auth.uid() OR
    -- Or you're an admin
    EXISTS (
      SELECT 1 FROM group_members gm
      WHERE gm.group_id = group_members.group_id
      AND gm.user_id = auth.uid()
      AND gm.role = 'admin'
    )
  );

-- ============================================
-- 2. VERIFY GROUPS POLICIES
-- ============================================
-- These should already be set, but let's make sure
DROP POLICY IF EXISTS "Users can view groups they're members of" ON groups;
DROP POLICY IF EXISTS "Authenticated users can create groups" ON groups;
DROP POLICY IF EXISTS "Group creators can update groups" ON groups;
DROP POLICY IF EXISTS "Group creators can delete groups" ON groups;

CREATE POLICY "View my groups" ON groups
  FOR SELECT USING (
    created_by = auth.uid() OR
    group_id IN (SELECT group_id FROM group_members WHERE user_id = auth.uid())
  );

CREATE POLICY "Create groups" ON groups
  FOR INSERT WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Update my groups" ON groups
  FOR UPDATE USING (created_by = auth.uid());

CREATE POLICY "Delete my groups" ON groups
  FOR DELETE USING (created_by = auth.uid());

-- ============================================
-- 3. FIX USERS TABLE POLICY (for finding users by email)
-- ============================================
DROP POLICY IF EXISTS "Users can view their own profile" ON users;
DROP POLICY IF EXISTS "Users can update their own profile" ON users;

-- Allow users to view ANY user profile (needed for adding members by email)
CREATE POLICY "View all users" ON users
  FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "Update own profile" ON users
  FOR UPDATE USING (user_id = auth.uid());
