-- ==============================================================================
-- SUPABASE CREATOR SUITE SCHEMA MIGRATION PATCH
-- Tables for Photographer & Videographer Portal:
-- 1. availability (Date-level availability, blocked slots, working hours)
-- 2. portfolio_media (Photos, videos, reels with categories & tags)
-- 3. payout_details (Bank & UPI creator payout configurations)
-- 4. notifications (Creator & customer real-time alerts)
-- ==============================================================================

-- 1. AVAILABILITY TABLE
CREATE TABLE IF NOT EXISTS public.availability (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    photographer_id UUID NOT NULL REFERENCES public.photographers(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    status TEXT NOT NULL DEFAULT 'AVAILABLE' CHECK (status IN ('AVAILABLE', 'BOOKED', 'BLOCKED', 'PARTIALLY_AVAILABLE')),
    start_time TEXT DEFAULT '09:00 AM',
    end_time TEXT DEFAULT '08:00 PM',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(photographer_id, date)
);

-- 2. PORTFOLIO MEDIA TABLE
CREATE TABLE IF NOT EXISTS public.portfolio_media (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    photographer_id UUID NOT NULL REFERENCES public.photographers(id) ON DELETE CASCADE,
    title TEXT NOT NULL DEFAULT '',
    description TEXT,
    media_url TEXT NOT NULL,
    thumbnail_url TEXT,
    media_type TEXT NOT NULL DEFAULT 'PHOTO' CHECK (media_type IN ('PHOTO', 'VIDEO', 'REEL')),
    category TEXT NOT NULL DEFAULT 'Portrait',
    style_tag TEXT DEFAULT 'Cinematic',
    is_featured BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. PAYOUT DETAILS TABLE
CREATE TABLE IF NOT EXISTS public.payout_details (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    photographer_id UUID UNIQUE NOT NULL REFERENCES public.photographers(id) ON DELETE CASCADE,
    account_holder_name TEXT NOT NULL,
    bank_name TEXT NOT NULL,
    account_number_mask TEXT NOT NULL,
    ifsc_code TEXT NOT NULL,
    upi_id TEXT,
    payout_status TEXT NOT NULL DEFAULT 'active' CHECK (payout_status IN ('pending_verification', 'active', 'suspended')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. NOTIFICATIONS TABLE
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'booking_request',
    booking_id UUID REFERENCES public.bookings(id) ON DELETE CASCADE,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. EXTEND PACKAGES TABLE IF EXTRA COLUMNS ARE NOT YET PRESENT
ALTER TABLE public.packages ADD COLUMN IF NOT EXISTS service_type TEXT DEFAULT 'Photography';
ALTER TABLE public.packages ADD COLUMN IF NOT EXISTS num_photographers INT DEFAULT 1;
ALTER TABLE public.packages ADD COLUMN IF NOT EXISTS num_videographers INT DEFAULT 0;
ALTER TABLE public.packages ADD COLUMN IF NOT EXISTS video_duration_minutes INT DEFAULT 0;
ALTER TABLE public.packages ADD COLUMN IF NOT EXISTS num_reels INT DEFAULT 0;
ALTER TABLE public.packages ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;
ALTER TABLE public.packages ADD COLUMN IF NOT EXISTS add_ons JSONB DEFAULT '[]'::JSONB;

-- 6. EXTEND PHOTOGRAPHERS TABLE
ALTER TABLE public.photographers ADD COLUMN IF NOT EXISTS service_area TEXT DEFAULT 'Mumbai & Surrounding Areas';
ALTER TABLE public.photographers ADD COLUMN IF NOT EXISTS creator_type TEXT DEFAULT 'both';
ALTER TABLE public.photographers ADD COLUMN IF NOT EXISTS is_online BOOLEAN DEFAULT TRUE;
ALTER TABLE public.photographers ADD COLUMN IF NOT EXISTS completed_shoots_count INT DEFAULT 24;
ALTER TABLE public.photographers ADD COLUMN IF NOT EXISTS response_rate NUMERIC(3,2) DEFAULT 0.98;
ALTER TABLE public.photographers ADD COLUMN IF NOT EXISTS working_hours_start TEXT DEFAULT '08:00 AM';
ALTER TABLE public.photographers ADD COLUMN IF NOT EXISTS working_hours_end TEXT DEFAULT '09:00 PM';

-- 7. ENABLE ROW LEVEL SECURITY
ALTER TABLE public.availability ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portfolio_media ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payout_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- 8. PERMISSIVE POLICIES
DROP POLICY IF EXISTS "Public read availability" ON public.availability;
CREATE POLICY "Public read availability" ON public.availability FOR SELECT USING (true);
DROP POLICY IF EXISTS "Public insert availability" ON public.availability;
CREATE POLICY "Public insert availability" ON public.availability FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Public update availability" ON public.availability;
CREATE POLICY "Public update availability" ON public.availability FOR UPDATE USING (true);
DROP POLICY IF EXISTS "Public delete availability" ON public.availability;
CREATE POLICY "Public delete availability" ON public.availability FOR DELETE USING (true);

DROP POLICY IF EXISTS "Public read portfolio_media" ON public.portfolio_media;
CREATE POLICY "Public read portfolio_media" ON public.portfolio_media FOR SELECT USING (true);
DROP POLICY IF EXISTS "Public insert portfolio_media" ON public.portfolio_media;
CREATE POLICY "Public insert portfolio_media" ON public.portfolio_media FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Public update portfolio_media" ON public.portfolio_media;
CREATE POLICY "Public update portfolio_media" ON public.portfolio_media FOR UPDATE USING (true);
DROP POLICY IF EXISTS "Public delete portfolio_media" ON public.portfolio_media;
CREATE POLICY "Public delete portfolio_media" ON public.portfolio_media FOR DELETE USING (true);

DROP POLICY IF EXISTS "Public read payout_details" ON public.payout_details;
CREATE POLICY "Public read payout_details" ON public.payout_details FOR SELECT USING (true);
DROP POLICY IF EXISTS "Public insert payout_details" ON public.payout_details;
CREATE POLICY "Public insert payout_details" ON public.payout_details FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Public update payout_details" ON public.payout_details;
CREATE POLICY "Public update payout_details" ON public.payout_details FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Public read notifications" ON public.notifications;
CREATE POLICY "Public read notifications" ON public.notifications FOR SELECT USING (true);
DROP POLICY IF EXISTS "Public insert notifications" ON public.notifications;
CREATE POLICY "Public insert notifications" ON public.notifications FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Public update notifications" ON public.notifications;
CREATE POLICY "Public update notifications" ON public.notifications FOR UPDATE USING (true);

-- 9. ADD TABLES TO REALTIME PUBLICATION
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.availability;
        ALTER PUBLICATION supabase_realtime ADD TABLE public.portfolio_media;
        ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
    END IF;
EXCEPTION
    WHEN duplicate_object THEN
        RAISE NOTICE 'Table already in publication';
END $$;

NOTIFY pgrst, 'reload schema';
