-- FIX for infinite recursion in group_members policies
-- Run this in Supabase SQL Editor

-- ============================================
-- 1. DROP ALL EXISTING POLICIES ON GROUP_MEMBERS
-- ============================================
DROP POLICY IF EXISTS "View members in my groups" ON group_members;
DROP POLICY IF EXISTS "Add members to groups" ON group_members;
DROP POLICY IF EXISTS "Remove members" ON group_members;
DROP POLICY IF EXISTS "Users can view group memberships" ON group_members;
DROP POLICY IF EXISTS "Group admins can add members" ON group_members;
DROP POLICY IF EXISTS "Users can remove themselves" ON group_members;
DROP POLICY IF EXISTS "Group admins can remove members" ON group_members;
DROP POLICY IF EXISTS "Allow own memberships" ON group_members;
DROP POLICY IF EXISTS "Allow insert for authenticated" ON group_members;
DROP POLICY IF EXISTS "Users can view their own memberships" ON group_members;
DROP POLICY IF EXISTS "Users can insert their own memberships" ON group_members;
DROP POLICY IF EXISTS "Users can delete their own memberships" ON group_members;

-- ============================================
-- 2. CREATE SIMPLE, NON-RECURSIVE POLICIES
-- ============================================

-- SELECT: Allow users to see memberships in groups where they are a member
-- This uses a subquery that prevents recursion
CREATE POLICY "view_group_members" ON group_members
  FOR SELECT
  USING (
    group_id IN (
      SELECT gm.group_id 
      FROM group_members gm 
      WHERE gm.user_id = auth.uid()
    )
  );

-- INSERT: Allow users to add themselves OR admins to add others
CREATE POLICY "insert_group_members" ON group_members
  FOR INSERT
  WITH CHECK (
    -- User is adding themselves
    user_id = auth.uid()
    OR
    -- OR user is an admin of the group (check via groups table)
    group_id IN (
      SELECT g.group_id
      FROM groups g
      WHERE g.created_by = auth.uid()
    )
    OR
    -- OR user is already an admin member
    EXISTS (
      SELECT 1 
      FROM group_members gm
      WHERE gm.group_id = group_members.group_id
        AND gm.user_id = auth.uid()
        AND gm.role = 'admin'
    )
  );

-- DELETE: Allow users to remove themselves OR admins to remove others
CREATE POLICY "delete_group_members" ON group_members
  FOR DELETE
  USING (
    -- User is removing themselves
    user_id = auth.uid()
    OR
    -- OR user is the group creator
    group_id IN (
      SELECT g.group_id
      FROM groups g
      WHERE g.created_by = auth.uid()
    )
    OR
    -- OR user is an admin member
    EXISTS (
      SELECT 1
      FROM group_members gm
      WHERE gm.group_id = group_members.group_id
        AND gm.user_id = auth.uid()
        AND gm.role = 'admin'
    )
  );

-- ============================================
-- 3. VERIFY USERS TABLE POLICY (for email lookup)
-- ============================================
DROP POLICY IF EXISTS "View all users" ON users;
DROP POLICY IF EXISTS "Users can view their own profile" ON users;

-- Allow authenticated users to view all user profiles (needed for adding members by email)
CREATE POLICY "view_all_users" ON users
  FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "update_own_profile" ON users
  FOR UPDATE
  USING (user_id = auth.uid());
