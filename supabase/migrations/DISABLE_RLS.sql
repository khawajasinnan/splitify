-- ============================================
-- DISABLE RLS (Row Level Security) ON ALL TABLES
-- This will allow your app to work without policy restrictions
-- Run this in Supabase SQL Editor
-- ============================================

-- Disable RLS on all Splitlify tables
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.groups DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_members DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.expense_splits DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.settlements DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions DISABLE ROW LEVEL SECURITY;

-- Optional: Drop all existing policies to clean up
DO $$ 
DECLARE 
    r RECORD;
BEGIN
    -- Drop policies from users
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'users') LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON users';
    END LOOP;
    
    -- Drop policies from groups
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'groups') LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON groups';
    END LOOP;
    
    -- Drop policies from group_members
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'group_members') LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON group_members';
    END LOOP;
    
    -- Drop policies from expenses
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'expenses') LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON expenses';
    END LOOP;
    
    -- Drop policies from expense_splits
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'expense_splits') LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON expense_splits';
    END LOOP;
    
    -- Drop policies from settlements
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'settlements') LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON settlements';
    END LOOP;
    
    -- Drop policies from transactions
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'transactions') LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON transactions';
    END LOOP;
END $$;

-- Verification query - Run this to confirm RLS is disabled
SELECT 
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public' 
    AND tablename IN ('users', 'groups', 'group_members', 'categories', 'expenses', 'expense_splits', 'settlements', 'transactions')
ORDER BY tablename;

-- You should see "false" for all tables after running this script
