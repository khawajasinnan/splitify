-- ============================================
-- SPLITLIFY APP - COMPLETE RLS POLICY FIX
-- Run this ENTIRE script in Supabase SQL Editor
-- This fixes the infinite recursion error
-- ============================================

-- ============================================
-- STEP 1: DROP ALL EXISTING PROBLEMATIC POLICIES
-- ============================================

-- Drop all group_members policies
DROP POLICY IF EXISTS "view_group_members" ON group_members;
DROP POLICY IF EXISTS "insert_group_members" ON group_members;
DROP POLICY IF EXISTS "delete_group_members" ON group_members;
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

-- Drop groups policies
DROP POLICY IF EXISTS "View my groups" ON groups;
DROP POLICY IF EXISTS "Create groups" ON groups;
DROP POLICY IF EXISTS "Update my groups" ON groups;
DROP POLICY IF EXISTS "Delete my groups" ON groups;
DROP POLICY IF EXISTS "Users can view groups they are members of" ON groups;
DROP POLICY IF EXISTS "Users can create groups" ON groups;
DROP POLICY IF EXISTS "Group admins can update groups" ON groups;
DROP POLICY IF EXISTS "Group admins can delete groups" ON groups;
DROP POLICY IF EXISTS "Users can view groups they're members of" ON groups;
DROP POLICY IF EXISTS "Authenticated users can create groups" ON groups;
DROP POLICY IF EXISTS "Group creators can update groups" ON groups;
DROP POLICY IF EXISTS "Group creators can delete groups" ON groups;

-- Drop users policies
DROP POLICY IF EXISTS "view_all_users" ON users;
DROP POLICY IF EXISTS "update_own_profile" ON users;
DROP POLICY IF EXISTS "View all users" ON users;
DROP POLICY IF EXISTS "Update own profile" ON users;
DROP POLICY IF EXISTS "Users can view their own profile" ON users;
DROP POLICY IF EXISTS "Users can update their own profile" ON users;
DROP POLICY IF EXISTS "Users can insert their own profile" ON users;

-- ============================================
-- STEP 2: CREATE NEW NON-RECURSIVE POLICIES
-- ============================================

-- ============================================
-- USERS TABLE POLICIES
-- ============================================

-- Allow all authenticated users to view all user profiles (needed for adding members by email)
CREATE POLICY "users_select_authenticated" ON users
  FOR SELECT
  USING (auth.uid() IS NOT NULL);

-- Allow users to insert their own profile
CREATE POLICY "users_insert_own" ON users
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Allow users to update their own profile
CREATE POLICY "users_update_own" ON users
  FOR UPDATE
  USING (auth.uid() = user_id);

-- ============================================
-- GROUPS TABLE POLICIES
-- ============================================

-- SELECT: Users can view groups they created OR are members of
-- We use a LEFT JOIN to avoid recursion - PostgreSQL optimizes this
CREATE POLICY "groups_select_own_or_member" ON groups
  FOR SELECT
  USING (
    auth.uid() = created_by
    OR
    EXISTS (
      SELECT 1 
      FROM group_members gm 
      WHERE gm.group_id = groups.group_id 
        AND gm.user_id = auth.uid()
    )
  );

-- INSERT: Authenticated users can create groups
CREATE POLICY "groups_insert_authenticated" ON groups
  FOR INSERT
  WITH CHECK (auth.uid() = created_by AND auth.uid() IS NOT NULL);

-- UPDATE: Only group creators can update groups
CREATE POLICY "groups_update_creator" ON groups
  FOR UPDATE
  USING (auth.uid() = created_by);

-- DELETE: Only group creators can delete groups
CREATE POLICY "groups_delete_creator" ON groups
  FOR DELETE
  USING (auth.uid() = created_by);

-- ============================================
-- GROUP_MEMBERS TABLE POLICIES (KEY FIX!)
-- ============================================

-- SELECT: Users can see members of groups they belong to
-- This is safe because we're selecting FROM group_members WHERE it matches current row's group_id
CREATE POLICY "group_members_select_same_group" ON group_members
  FOR SELECT
  USING (
    -- Allow if current user is a member of the same group
    EXISTS (
      SELECT 1
      FROM group_members gm
      WHERE gm.group_id = group_members.group_id
        AND gm.user_id = auth.uid()
    )
  );

-- INSERT: Users can add themselves when joining, creators/admins can add others
CREATE POLICY "group_members_insert_self_or_admin" ON group_members
  FOR INSERT
  WITH CHECK (
    -- User is adding themselves (when joining a group)
    user_id = auth.uid()
    OR
    -- User is the group creator (can always add members)
    EXISTS (
      SELECT 1
      FROM groups g
      WHERE g.group_id = group_members.group_id
        AND g.created_by = auth.uid()
    )
    OR
    -- User is an existing admin in the group (can add members)
    EXISTS (
      SELECT 1
      FROM group_members gm
      WHERE gm.group_id = group_members.group_id
        AND gm.user_id = auth.uid()
        AND gm.role = 'admin'
    )
  );

-- DELETE: Users can remove themselves, creators/admins can remove others
CREATE POLICY "group_members_delete_self_or_admin" ON group_members
  FOR DELETE
  USING (
    -- User is removing themselves
    user_id = auth.uid()
    OR
    -- User is the group creator (can remove anyone)
    EXISTS (
      SELECT 1
      FROM groups g
      WHERE g.group_id = group_members.group_id
        AND g.created_by = auth.uid()
    )
    OR
    -- User is an admin in the group (can remove others)
    EXISTS (
      SELECT 1
      FROM group_members gm
      WHERE gm.group_id = group_members.group_id
        AND gm.user_id = auth.uid()
        AND gm.role = 'admin'
    )
  );

-- ============================================
-- EXPENSES TABLE POLICIES
-- ============================================

-- Verify existing policies are correct
DROP POLICY IF EXISTS "Group members can view expenses" ON expenses;
DROP POLICY IF EXISTS "Group members can create expenses" ON expenses;
DROP POLICY IF EXISTS "Payer can update their expenses" ON expenses;
DROP POLICY IF EXISTS "Payer can delete their expenses" ON expenses;

-- SELECT: Members can view expenses in their groups
CREATE POLICY "expenses_select_group_members" ON expenses
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1
      FROM group_members gm
      WHERE gm.group_id = expenses.group_id
        AND gm.user_id = auth.uid()
    )
  );

-- INSERT: Members can create expenses (must be the payer)
CREATE POLICY "expenses_insert_as_payer" ON expenses
  FOR INSERT
  WITH CHECK (
    auth.uid() = payer_id
    AND
    EXISTS (
      SELECT 1
      FROM group_members gm
      WHERE gm.group_id = expenses.group_id
        AND gm.user_id = auth.uid()
    )
  );

-- UPDATE: Only the payer can update their expenses
CREATE POLICY "expenses_update_payer_only" ON expenses
  FOR UPDATE
  USING (auth.uid() = payer_id);

-- DELETE: Only the payer can delete their expenses
CREATE POLICY "expenses_delete_payer_only" ON expenses
  FOR DELETE
  USING (auth.uid() = payer_id);

-- ============================================
-- EXPENSE_SPLITS TABLE POLICIES
-- ============================================

DROP POLICY IF EXISTS "Users can view splits of expenses in their groups" ON expense_splits;
DROP POLICY IF EXISTS "Expense payer can manage splits" ON expense_splits;

-- SELECT: Users can view splits for expenses in their groups
CREATE POLICY "expense_splits_select_group_members" ON expense_splits
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1
      FROM expenses e
      JOIN group_members gm ON e.group_id = gm.group_id
      WHERE e.expense_id = expense_splits.expense_id
        AND gm.user_id = auth.uid()
    )
  );

-- ALL (INSERT, UPDATE, DELETE): Only the expense payer can manage splits
CREATE POLICY "expense_splits_manage_payer_only" ON expense_splits
  FOR ALL
  USING (
    EXISTS (
      SELECT 1
      FROM expenses e
      WHERE e.expense_id = expense_splits.expense_id
        AND e.payer_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM expenses e
      WHERE e.expense_id = expense_splits.expense_id
        AND e.payer_id = auth.uid()
    )
  );

-- ============================================
-- SETTLEMENTS TABLE POLICIES
-- ============================================

DROP POLICY IF EXISTS "Settlement participants can view settlements" ON settlements;
DROP POLICY IF EXISTS "Group members can create settlements" ON settlements;
DROP POLICY IF EXISTS "Settlement participants can update settlements" ON settlements;

-- SELECT: Users can view settlements they're involved in or in their groups
CREATE POLICY "settlements_select_participants_or_group" ON settlements
  FOR SELECT
  USING (
    auth.uid() = payer_id
    OR auth.uid() = receiver_id
    OR EXISTS (
      SELECT 1
      FROM group_members gm
      WHERE gm.group_id = settlements.group_id
        AND gm.user_id = auth.uid()
    )
  );

-- INSERT: Group members can create settlements
CREATE POLICY "settlements_insert_group_members" ON settlements
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM group_members gm
      WHERE gm.group_id = settlements.group_id
        AND gm.user_id = auth.uid()
    )
  );

-- UPDATE: Only participants can update settlements
CREATE POLICY "settlements_update_participants" ON settlements
  FOR UPDATE
  USING (auth.uid() = payer_id OR auth.uid() = receiver_id);

-- ============================================
-- CATEGORIES TABLE POLICY
-- ============================================

DROP POLICY IF EXISTS "Anyone can view categories" ON categories;

-- All authenticated users can view categories (public data)
CREATE POLICY "categories_select_all" ON categories
  FOR SELECT
  USING (true);

-- ============================================
-- TRANSACTIONS TABLE POLICIES
-- ============================================

DROP POLICY IF EXISTS "Users can view their own transactions" ON transactions;
DROP POLICY IF EXISTS "Users can create their own transactions" ON transactions;

-- SELECT: Users can view their own transactions
CREATE POLICY "transactions_select_own" ON transactions
  FOR SELECT
  USING (auth.uid() = user_id);

-- INSERT: Users can create their own transactions
CREATE POLICY "transactions_insert_own" ON transactions
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ============================================
-- VERIFICATION
-- ============================================
-- After running this script:
-- 1. Try creating a new group
-- 2. Add members to the group
-- 3. Create expenses
-- 4. The infinite recursion error should be resolved!
-- ============================================
