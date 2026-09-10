-- ==============================================================================
-- SUPABASE MIGRATION PATCH: REALTIME REPLICATION, RLS, & BOOKING SCHEMA
-- Run this in Supabase SQL Editor (Dashboard > SQL Editor > New Query)
-- ==============================================================================

-- 1. ENABLE REALTIME REPLICATION ON REQUIRED TABLES
-- This fixes RealtimeSubscribeException (channelError)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.bookings;
        ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
        ALTER PUBLICATION supabase_realtime ADD TABLE public.users;
    END IF;
EXCEPTION
    WHEN duplicate_object THEN
        RAISE NOTICE 'Table already in publication';
END $$;

-- 2. ADD COMPATIBILITY COLUMNS TO BOOKINGS (PREVENTS PGRST204)
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS customer_avatar TEXT;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS customer_name TEXT;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS customer_phone TEXT;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS photographer_name TEXT;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS photographer_avatar TEXT;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS package_title TEXT;
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS event_type TEXT;

-- 3. PERMISSIVE ROW LEVEL SECURITY POLICIES (COMPATIBLE WITH HYBRID AUTH & CDC)
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.photographers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deliverables ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read bookings" ON public.bookings;
CREATE POLICY "Public read bookings" ON public.bookings FOR SELECT USING (true);
DROP POLICY IF EXISTS "Public insert bookings" ON public.bookings;
CREATE POLICY "Public insert bookings" ON public.bookings FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Public update bookings" ON public.bookings;
CREATE POLICY "Public update bookings" ON public.bookings FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Public read messages" ON public.messages;
CREATE POLICY "Public read messages" ON public.messages FOR SELECT USING (true);
DROP POLICY IF EXISTS "Public insert messages" ON public.messages;
CREATE POLICY "Public insert messages" ON public.messages FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Public update messages" ON public.messages;
CREATE POLICY "Public update messages" ON public.messages FOR UPDATE USING (true);

-- 4. RELOAD POSTGREST SCHEMA CACHE
NOTIFY pgrst, 'reload schema';
