-- Fix for infinite recursion in group_members RLS policy
-- Run this in Supabase SQL Editor to fix the error

-- Drop existing problematic policies
DROP POLICY IF EXISTS "Users can view their group memberships" ON group_members;
DROP POLICY IF EXISTS "Users can view memberships in their groups" ON group_members;
DROP POLICY IF EXISTS "Users can join groups" ON group_members;
DROP POLICY IF EXISTS "Group admins can add members" ON group_members;
DROP POLICY IF EXISTS "Users can leave groups" ON group_members;

-- Create simplified policies without circular references
CREATE POLICY "Users can view group memberships"
  ON group_members FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Group admins can add members"
  ON group_members FOR INSERT
  WITH CHECK (
    user_id = auth.uid() OR
    auth.uid() IN (
      SELECT gm.user_id FROM group_members gm 
      WHERE gm.group_id = group_members.group_id 
      AND gm.role = 'admin'
      LIMIT 1
    )
  );

CREATE POLICY "Users can remove themselves"
  ON group_members FOR DELETE
  USING (user_id = auth.uid());

CREATE POLICY "Group admins can remove members"
  ON group_members FOR DELETE
  USING (
    auth.uid() IN (
      SELECT user_id FROM group_members 
      WHERE group_id = group_members.group_id 
      AND role = 'admin'
      AND user_id != group_members.user_id
    )
  );
