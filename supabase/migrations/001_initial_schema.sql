-- Splitlify Database Schema for Supabase
-- Run this in your Supabase SQL editor to create all tables

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.users (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Groups table
CREATE TABLE IF NOT EXISTS public.groups (
    group_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    created_by UUID NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Group members junction table
CREATE TABLE IF NOT EXISTS public.group_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_id UUID NOT NULL REFERENCES public.groups(group_id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('admin', 'member')),
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(group_id, user_id)
);

-- Categories table
CREATE TABLE IF NOT EXISTS public.categories (
    category_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    type TEXT NOT NULL,
    icon TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Expenses table
CREATE TABLE IF NOT EXISTS public.expenses (
    expense_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_id UUID NOT NULL REFERENCES public.groups(group_id) ON DELETE CASCADE,
    category_id UUID REFERENCES public.categories(category_id) ON DELETE SET NULL,
    payer_id UUID NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    description TEXT NOT NULL,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    split_type TEXT NOT NULL DEFAULT 'equal' CHECK (split_type IN ('equal', 'percentage', 'custom')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Expense splits table
CREATE TABLE IF NOT EXISTS public.expense_splits (
    split_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    expense_id UUID NOT NULL REFERENCES public.expenses(expense_id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount >= 0),
    share_percentage DECIMAL(5, 2) CHECK (share_percentage >= 0 AND share_percentage <= 100),
    UNIQUE(expense_id, user_id)
);

-- Settlements table
CREATE TABLE IF NOT EXISTS public.settlements (
    settlement_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_id UUID NOT NULL REFERENCES public.groups(group_id) ON DELETE CASCADE,
    payer_id UUID NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    receiver_id UUID NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'cancelled')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    settled_at TIMESTAMP WITH TIME ZONE,
    CHECK (payer_id != receiver_id)
);

-- Transactions table (audit log)
CREATE TABLE IF NOT EXISTS public.transactions (
    transaction_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('expense', 'settlement', 'payment')),
    amount DECIMAL(10, 2) NOT NULL,
    description TEXT NOT NULL,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_group_members_group_id ON public.group_members(group_id);
CREATE INDEX IF NOT EXISTS idx_group_members_user_id ON public.group_members(user_id);
CREATE INDEX IF NOT EXISTS idx_expenses_group_id ON public.expenses(group_id);
CREATE INDEX IF NOT EXISTS idx_expenses_payer_id ON public.expenses(payer_id);
CREATE INDEX IF NOT EXISTS idx_expense_splits_expense_id ON public.expense_splits(expense_id);
CREATE INDEX IF NOT EXISTS idx_expense_splits_user_id ON public.expense_splits(user_id);
CREATE INDEX IF NOT EXISTS idx_settlements_group_id ON public.settlements(group_id);
CREATE INDEX IF NOT EXISTS idx_settlements_payer_id ON public.settlements(payer_id);
CREATE INDEX IF NOT EXISTS idx_settlements_receiver_id ON public.settlements(receiver_id);
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON public.transactions(user_id);

-- Insert default categories
INSERT INTO public.categories (name, type, icon) VALUES
    ('Food & Dining', 'expense', '🍔'),
    ('Transportation', 'expense', '🚗'),
    ('Shopping', 'expense', '🛍️'),
    ('Entertainment', 'expense', '🎬'),
    ('Utilities', 'expense', '💡'),
    ('Healthcare', 'expense', '🏥'),
    ('Education', 'expense', '📚'),
    ('Travel', 'expense', '✈️'),
    ('Groceries', 'expense', '🛒'),
    ('Other', 'expense', '📌')
ON CONFLICT (name) DO NOTHING;

-- Row Level Security (RLS) Policies

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expense_splits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.settlements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view their own profile" ON public.users
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own profile" ON public.users
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Groups policies
CREATE POLICY "Users can view groups they are members of" ON public.groups
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.group_members
            WHERE group_members.group_id = groups.group_id
            AND group_members.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can create groups" ON public.groups
    FOR INSERT WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Group admins can update groups" ON public.groups
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.group_members
            WHERE group_members.group_id = groups.group_id
            AND group_members.user_id = auth.uid()
            AND group_members.role = 'admin'
        )
    );

CREATE POLICY "Group admins can delete groups" ON public.groups
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.group_members
            WHERE group_members.group_id = groups.group_id
            AND group_members.user_id = auth.uid()
            AND group_members.role = 'admin'
        )
    );

-- Row Level Security Policies for group_members
-- RLS is already enabled above, but keeping this comment for context.

-- Allow users to view memberships for groups they belong to
CREATE POLICY "Users can view group memberships"
  ON public.group_members FOR SELECT
  USING (user_id = auth.uid());

-- Allow group admins to insert new members
CREATE POLICY "Group admins can add members"
  ON public.group_members FOR INSERT
  WITH CHECK (
    user_id = auth.uid() OR
    auth.uid() IN (
      SELECT gm.user_id FROM public.group_members gm 
      WHERE gm.group_id = public.group_members.group_id 
      AND gm.role = 'admin'
      LIMIT 1
    )
  );

-- Allow users to leave groups
CREATE POLICY "Users can remove themselves"
  ON public.group_members FOR DELETE
  USING (user_id = auth.uid());

-- Allow group admins to remove members
CREATE POLICY "Group admins can remove members"
  ON public.group_members FOR DELETE
  USING (
    auth.uid() IN (
      SELECT user_id FROM public.group_members 
      WHERE group_id = public.group_members.group_id 
      AND role = 'admin'
      AND user_id != public.group_members.user_id
    )
  );

-- Categories policies (public read access)
CREATE POLICY "Anyone can view categories" ON public.categories
    FOR SELECT USING (true);

-- Expenses policies
CREATE POLICY "Group members can view expenses" ON public.expenses
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.group_members
            WHERE group_members.group_id = expenses.group_id
            AND group_members.user_id = auth.uid()
        )
    );

CREATE POLICY "Group members can create expenses" ON public.expenses
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.group_members
            WHERE group_members.group_id = expenses.group_id
            AND group_members.user_id = auth.uid()
        ) AND auth.uid() = payer_id
    );

CREATE POLICY "Payer can update their expenses" ON public.expenses
    FOR UPDATE USING (auth.uid() = payer_id);

CREATE POLICY "Payer can delete their expenses" ON public.expenses
    FOR DELETE USING (auth.uid() = payer_id);

-- Expense splits policies
CREATE POLICY "Users can view splits of expenses in their groups" ON public.expense_splits
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.expenses e
            JOIN public.group_members gm ON e.group_id = gm.group_id
            WHERE e.expense_id = expense_splits.expense_id
            AND gm.user_id = auth.uid()
        )
    );

CREATE POLICY "Expense payer can manage splits" ON public.expense_splits
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.expenses
            WHERE expenses.expense_id = expense_splits.expense_id
            AND expenses.payer_id = auth.uid()
        )
    );

-- Settlements policies
CREATE POLICY "Settlement participants can view settlements" ON public.settlements
    FOR SELECT USING (
        auth.uid() = payer_id OR 
        auth.uid() = receiver_id OR
        EXISTS (
            SELECT 1 FROM public.group_members
            WHERE group_members.group_id = settlements.group_id
            AND group_members.user_id = auth.uid()
        )
    );

CREATE POLICY "Group members can create settlements" ON public.settlements
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.group_members
            WHERE group_members.group_id = settlements.group_id
            AND group_members.user_id = auth.uid()
        )
    );

CREATE POLICY "Settlement participants can update settlements" ON public.settlements
    FOR UPDATE USING (
        auth.uid() = payer_id OR auth.uid() = receiver_id
    );

-- Transactions policies
CREATE POLICY "Users can view their own transactions" ON public.transactions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own transactions" ON public.transactions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers to update updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_groups_updated_at BEFORE UPDATE ON public.groups
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_expenses_updated_at BEFORE UPDATE ON public.expenses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to create user profile after signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (user_id, name, email)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'name', 'User'),
        NEW.email
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create user profile
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
