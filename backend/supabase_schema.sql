-- Enable the UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Drop existing tables to avoid "already exists" errors
DROP TABLE IF EXISTS public.messages CASCADE;
DROP TABLE IF EXISTS public.conversations CASCADE;

-- ==========================================
-- 1. CONVERSATIONS TABLE
-- ==========================================
CREATE TABLE public.conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL DEFAULT 'New Legal Chat',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Turn on Row Level Security
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;

-- Policies for conversations: Users can only see and modify their own conversations
CREATE POLICY "Users can insert their own conversations" 
ON public.conversations FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can select their own conversations" 
ON public.conversations FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own conversations" 
ON public.conversations FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own conversations" 
ON public.conversations FOR DELETE 
USING (auth.uid() = user_id);

-- ==========================================
-- 2. MESSAGES TABLE
-- ==========================================
CREATE TABLE public.messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'model')),
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Turn on Row Level Security
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Policies for messages: Users can only see and modify messages in their own conversations
CREATE POLICY "Users can insert messages to their own conversations" 
ON public.messages FOR INSERT 
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.conversations c 
        WHERE c.id = conversation_id AND c.user_id = auth.uid()
    )
);

CREATE POLICY "Users can select messages from their own conversations" 
ON public.messages FOR SELECT 
USING (
    EXISTS (
        SELECT 1 FROM public.conversations c 
        WHERE c.id = conversation_id AND c.user_id = auth.uid()
    )
);

CREATE POLICY "Users can update messages in their own conversations" 
ON public.messages FOR UPDATE 
USING (
    EXISTS (
        SELECT 1 FROM public.conversations c 
        WHERE c.id = conversation_id AND c.user_id = auth.uid()
    )
);

CREATE POLICY "Users can delete messages in their own conversations" 
ON public.messages FOR DELETE 
USING (
    EXISTS (
        SELECT 1 FROM public.conversations c 
        WHERE c.id = conversation_id AND c.user_id = auth.uid()
    )
);

-- ==========================================
-- 3. TRIGGERS
-- ==========================================
-- Automatically update updated_at timestamp in conversations
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_conversations_updated_at
    BEFORE UPDATE ON public.conversations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
