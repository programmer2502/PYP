-- ==============================================================================
-- PYP (Pick Your Photographer) - Supabase Complete Seed & Setup Script
-- Run this script in your Supabase SQL Editor: https://supabase.com/dashboard/project/ovtlrihpmetlxxkyxprx/sql
-- ==============================================================================

-- 1. Enable UUID Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. CREATE / ENSURE ALL TABLES EXIST
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    avatar_url TEXT,
    role TEXT NOT NULL DEFAULT 'customer' CHECK (role IN ('customer', 'creator', 'admin')),
    location TEXT DEFAULT 'Mumbai, India',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.categories (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    icon TEXT,
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.photographers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    bio TEXT,
    tagline TEXT,
    avatar_url TEXT,
    cover_url TEXT,
    location TEXT NOT NULL,
    latitude DOUBLE PRECISION DEFAULT 19.0760,
    longitude DOUBLE PRECISION DEFAULT 72.8777,
    rating NUMERIC(3,2) DEFAULT 4.90,
    review_count INT DEFAULT 0,
    starting_price NUMERIC(10,2) NOT NULL DEFAULT 4999.00,
    is_verified BOOLEAN DEFAULT TRUE,
    is_available BOOLEAN DEFAULT TRUE,
    categories TEXT[] DEFAULT ARRAY['Portrait', 'Editorial'],
    styles TEXT[] DEFAULT ARRAY['Cinematic', 'Editorial', 'Moody & Dark'],
    equipment TEXT[] DEFAULT ARRAY['Sony A7 IV', '85mm f/1.4 GM', 'Profoto B10'],
    experience_years INT DEFAULT 5,
    portfolio_images TEXT[] DEFAULT ARRAY[]::TEXT[],
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.packages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    photographer_id UUID NOT NULL REFERENCES public.photographers(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    duration_hours INT NOT NULL DEFAULT 2,
    price NUMERIC(10,2) NOT NULL,
    photos_count INT NOT NULL DEFAULT 30,
    delivery_days INT NOT NULL DEFAULT 5,
    features TEXT[] DEFAULT ARRAY['Color Graded Raw Deliverables', 'Online High-Res Gallery'],
    is_popular BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_number TEXT UNIQUE NOT NULL,
    customer_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    photographer_id UUID NOT NULL REFERENCES public.photographers(id) ON DELETE CASCADE,
    package_id UUID REFERENCES public.packages(id) ON DELETE SET NULL,
    shoot_date TIMESTAMPTZ NOT NULL,
    time_slot TEXT NOT NULL,
    duration_hours INT NOT NULL DEFAULT 2,
    venue TEXT NOT NULL,
    latitude DOUBLE PRECISION DEFAULT 19.0596,
    longitude DOUBLE PRECISION DEFAULT 72.8295,
    status TEXT NOT NULL DEFAULT 'requested' CHECK (status IN ('requested', 'confirmed', 'shoot_day', 'editing', 'delivered', 'completed', 'cancelled')),
    notes TEXT,
    subtotal NUMERIC(10,2) NOT NULL,
    platform_fee NUMERIC(10,2) NOT NULL,
    tax NUMERIC(10,2) NOT NULL,
    total_amount NUMERIC(10,2) NOT NULL,
    razorpay_order_id TEXT,
    razorpay_payment_id TEXT,
    last_message TEXT,
    last_message_time TIMESTAMPTZ,
    last_sender_id UUID REFERENCES public.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    sender_name TEXT NOT NULL,
    sender_avatar TEXT,
    text TEXT NOT NULL DEFAULT '',
    media_url TEXT,
    media_type TEXT NOT NULL DEFAULT 'text' CHECK (media_type IN ('text', 'image', 'booking_card', 'location', 'timeline')),
    metadata JSONB,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID REFERENCES public.bookings(id) ON DELETE SET NULL,
    customer_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    photographer_id UUID NOT NULL REFERENCES public.photographers(id) ON DELETE CASCADE,
    rating NUMERIC(2,1) NOT NULL CHECK (rating >= 1.0 AND rating <= 5.0),
    comment TEXT NOT NULL,
    customer_name TEXT NOT NULL,
    customer_avatar TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.deliverables (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    file_name TEXT NOT NULL,
    file_url TEXT NOT NULL,
    file_type TEXT NOT NULL DEFAULT 'image' CHECK (file_type IN ('image', 'video', 'zip', 'raw')),
    file_size BIGINT DEFAULT 0,
    is_downloaded BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Relax NOT NULL constraints for flexible client & seed usage
ALTER TABLE IF EXISTS public.reviews ALTER COLUMN customer_id DROP NOT NULL;
ALTER TABLE IF EXISTS public.reviews ALTER COLUMN booking_id DROP NOT NULL;
ALTER TABLE IF EXISTS public.bookings ALTER COLUMN customer_id DROP NOT NULL;

-- 4. Enable Row Level Security (RLS) & Permissive Policies
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.photographers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deliverables ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read users" ON public.users;
CREATE POLICY "Public read users" ON public.users FOR SELECT USING (true);
DROP POLICY IF EXISTS "Public insert users" ON public.users;
CREATE POLICY "Public insert users" ON public.users FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Public update users" ON public.users;
CREATE POLICY "Public update users" ON public.users FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Public read categories" ON public.categories;
CREATE POLICY "Public read categories" ON public.categories FOR SELECT USING (true);
DROP POLICY IF EXISTS "Public insert categories" ON public.categories;
CREATE POLICY "Public insert categories" ON public.categories FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Public read photographers" ON public.photographers;
CREATE POLICY "Public read photographers" ON public.photographers FOR SELECT USING (true);
DROP POLICY IF EXISTS "Public insert photographers" ON public.photographers;
CREATE POLICY "Public insert photographers" ON public.photographers FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Public update photographers" ON public.photographers;
CREATE POLICY "Public update photographers" ON public.photographers FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Public read packages" ON public.packages;
CREATE POLICY "Public read packages" ON public.packages FOR SELECT USING (true);
DROP POLICY IF EXISTS "Public insert packages" ON public.packages;
CREATE POLICY "Public insert packages" ON public.packages FOR INSERT WITH CHECK (true);

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

DROP POLICY IF EXISTS "Public read reviews" ON public.reviews;
CREATE POLICY "Public read reviews" ON public.reviews FOR SELECT USING (true);
DROP POLICY IF EXISTS "Public insert reviews" ON public.reviews;
CREATE POLICY "Public insert reviews" ON public.reviews FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Public read deliverables" ON public.deliverables;
CREATE POLICY "Public read deliverables" ON public.deliverables FOR SELECT USING (true);
DROP POLICY IF EXISTS "Public insert deliverables" ON public.deliverables;
CREATE POLICY "Public insert deliverables" ON public.deliverables FOR INSERT WITH CHECK (true);

-- ==============================================================================
-- 5. SEED DATA POPULATION
-- ==============================================================================

-- A. Insert Users First (Avoid FK issues)
INSERT INTO public.users (id, name, email, phone, avatar_url, role, location)
VALUES
(
    'e1111111-1111-1111-1111-111111111111',
    'Natasha Verma',
    'natasha.verma@example.com',
    '+91 98765 43210',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80',
    'customer',
    'Indiranagar, Bengaluru'
),
(
    'e2222222-2222-2222-2222-222222222222',
    'Rishi Kapoor',
    'rishi.kapoor@example.com',
    '+91 98123 45678',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80',
    'customer',
    'Bandra West, Mumbai'
),
(
    'e3333333-3333-3333-3333-333333333333',
    'Sunil Hegde',
    'sunil.hegde@example.com',
    '+91 99887 76655',
    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&q=80',
    'customer',
    'Whitefield, Bengaluru'
),
(
    'e4444444-4444-4444-4444-444444444444',
    'Naveen Raj',
    'r.r.naveenraj25@gmail.com',
    '+91 91234 56789',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
    'customer',
    'Bengaluru, Karnataka'
)
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, email = EXCLUDED.email;

-- B. Insert Categories
INSERT INTO public.categories (id, title, icon, image_url)
VALUES
('All', 'All', 'fa-solid fa-camera', NULL),
('Wedding', 'Wedding', NULL, 'https://images.unsplash.com/photo-1583939003579-730e3918a45a?w=200&q=80'),
('Portrait', 'Portrait', NULL, 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80'),
('Event', 'Event', NULL, 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=200&q=80'),
('Drone', 'Drone', NULL, 'https://images.unsplash.com/photo-1508614589041-895b88991e3e?w=200&q=80'),
('Reels', 'Reels', NULL, 'https://images.unsplash.com/photo-1574717024653-61fd2cf4d44d?w=200&q=80')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, image_url = EXCLUDED.image_url;

-- C. Insert Verified Photographers
INSERT INTO public.photographers (id, name, bio, tagline, avatar_url, cover_url, location, latitude, longitude, rating, review_count, starting_price, is_verified, is_available, categories, styles, equipment, experience_years, portfolio_images)
VALUES
(
    'a1111111-1111-1111-1111-111111111111',
    'Arjun Mehta',
    'Award-winning celebrity and high-fashion editorial photographer with 8+ years experience in Mumbai & Paris.',
    'Vogue Featured • Cinematic Light Specialist',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&q=80',
    'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=1200&q=80',
    'Indiranagar, Bengaluru',
    12.9716,
    77.5946,
    5.0,
    128,
    4999.00,
    TRUE,
    TRUE,
    ARRAY['Wedding', 'Portrait', 'Fashion', 'Reels'],
    ARRAY['Cinematic', 'Editorial', 'Moody & Dark', 'Vibrant & Warm'],
    ARRAY['Sony A7 IV', '85mm f/1.4 GM', '50mm f/1.2 GM', 'Profoto B10 Plus'],
    8,
    ARRAY[
        'https://images.unsplash.com/photo-1519741497674-611481863552?w=800&q=80',
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80',
        'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=800&q=80',
        'https://images.unsplash.com/photo-1537633552985-df8429e8048b?w=800&q=80'
    ]
),
(
    'a2222222-2222-2222-2222-222222222222',
    'Priya Sharma',
    'Specializing in royal destination weddings, candid emotional moments, and heirloom visual stories.',
    'Luxury Destination Wedding & Candid Storyteller',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=500&q=80',
    'https://images.unsplash.com/photo-1519741497674-611481863552?w=1200&q=80',
    'Koramangala, Bengaluru',
    12.9784,
    77.6408,
    4.9,
    94,
    7999.00,
    TRUE,
    TRUE,
    ARRAY['Wedding', 'Event', 'Portrait'],
    ARRAY['Candid', 'Vibrant & Warm', 'Cinematic'],
    ARRAY['Canon EOS R5', 'RF 28-70mm f/2 L', 'RF 70-200mm f/2.8 IS', 'Profoto A1X AirTTL'],
    6,
    ARRAY[
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800&q=80',
        'https://images.unsplash.com/photo-1519741497674-611481863552?w=800&q=80',
        'https://images.unsplash.com/photo-1537633552985-df8429e8048b?w=800&q=80'
    ]
),
(
    'a3333333-3333-3333-3333-333333333333',
    'Kabir Sen',
    'Viral social content, 4K vertical reels, dynamic cinematography, and DGCA certified drone coverage.',
    'Viral Reels & 4K Cinema Drone Specialist',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&q=80',
    'https://images.unsplash.com/photo-1508614589041-895b88991e3e?w=1200&q=80',
    'Whitefield, Bengaluru',
    12.9698,
    77.7499,
    4.9,
    76,
    3999.00,
    TRUE,
    TRUE,
    ARRAY['Drone', 'Reels', 'Event'],
    ARRAY['Cinematic', 'Vibrant & Warm', 'Commercial'],
    ARRAY['Sony FX3 Cinema Line', 'DJI Mavic 3 Pro Cine Drone', 'DJI RS3 Pro Gimbal', 'Sennheiser Wireless Mics'],
    5,
    ARRAY[
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&q=80',
        'https://images.unsplash.com/photo-1508614589041-895b88991e3e?w=800&q=80',
        'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800&q=80'
    ]
),
(
    'a4444444-4444-4444-4444-444444444444',
    'Aisha Khan',
    'Runway, luxury brands, and conceptual editorial lookbooks with European minimalist aesthetics.',
    'High-Fashion & Runway Editorial Director',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&q=80',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=1200&q=80',
    'Bandra West, Mumbai',
    19.0596,
    72.8295,
    5.0,
    110,
    6499.00,
    TRUE,
    TRUE,
    ARRAY['Portrait', 'Fashion'],
    ARRAY['Editorial', 'Moody & Dark', 'Fashion'],
    ARRAY['Hasselblad X2D 100C', 'Sony A7R V', 'Profoto B10X Plus', 'Broncolor Siros 800L'],
    9,
    ARRAY[
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80',
        'https://images.unsplash.com/photo-1519741497674-611481863552?w=800&q=80'
    ]
)
ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    bio = EXCLUDED.bio,
    tagline = EXCLUDED.tagline,
    avatar_url = EXCLUDED.avatar_url,
    starting_price = EXCLUDED.starting_price,
    categories = EXCLUDED.categories,
    portfolio_images = EXCLUDED.portfolio_images;

-- D. Insert Packages
INSERT INTO public.packages (id, photographer_id, title, description, duration_hours, price, photos_count, delivery_days, features, is_popular)
VALUES
(
    'b1111111-1111-1111-1111-111111111111',
    'a1111111-1111-1111-1111-111111111111',
    'Editorial Portrait Standard',
    'Ideal for portraits, personal branding, and high-fashion lookbooks.',
    2,
    4999.00,
    35,
    3,
    ARRAY['35 Hand Retouched Master Photos', 'Private Cloud High-Res Gallery', '2 Outfit Changes', '48hr Express Delivery'],
    TRUE
),
(
    'b2222222-2222-2222-2222-222222222222',
    'a1111111-1111-1111-1111-111111111111',
    'Cinematic Story & 4K Reels',
    'Celebrity photoshoot experience with lighting assistant & 4K vertical teaser.',
    4,
    8999.00,
    75,
    5,
    ARRAY['75 Color-Graded Photos', '3 Viral 4K Reels', 'Full Studio Lighting Setup', 'Drone Stills Included'],
    FALSE
),
(
    'b3333333-3333-3333-3333-333333333333',
    'a2222222-2222-2222-2222-222222222222',
    'Royal Wedding Day Milestone',
    'Comprehensive destination wedding coverage capturing every ritual and candid glance.',
    8,
    18999.00,
    250,
    7,
    ARRAY['250+ Master Photos', 'Traditional & Candid Dual Angles', 'Online Proofing Portal', 'Heirloom Velvet Album Voucher'],
    TRUE
),
(
    'b4444444-4444-4444-4444-444444444444',
    'a3333333-3333-3333-3333-333333333333',
    'Aerial 4K Drone Master',
    'High-resolution aerial perspectives for architectural estates and events.',
    3,
    3999.00,
    45,
    2,
    ARRAY['45 High-Res Aerial Stills', '3x Color-Graded 4K Video Clips', 'DGCA Flight Permits Handled', 'Same-Day Cloud Delivery'],
    TRUE
)
ON CONFLICT (id) DO UPDATE SET 
    title = EXCLUDED.title,
    price = EXCLUDED.price,
    features = EXCLUDED.features;

-- E. Insert Reviews (Safe with valid customer_id & fallback columns)
INSERT INTO public.reviews (id, customer_id, photographer_id, rating, comment, customer_name, customer_avatar)
VALUES
(
    'c1111111-1111-1111-1111-111111111111',
    'e1111111-1111-1111-1111-111111111111',
    'a1111111-1111-1111-1111-111111111111',
    5.0,
    'Arjun Mehta is a true master of lighting! The magazine-style portraits exceeded all expectations.',
    'Natasha Verma',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80'
),
(
    'c2222222-2222-2222-2222-222222222222',
    'e2222222-2222-2222-2222-222222222222',
    'a1111111-1111-1111-1111-111111111111',
    4.9,
    'Super fast 48h turnaround on the cloud gallery. The tones and depth of the photos are breathtaking. 10/10 recommend!',
    'Rishi Kapoor',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80'
),
(
    'c3333333-3333-3333-3333-333333333333',
    'e3333333-3333-3333-3333-333333333333',
    'a3333333-3333-3333-3333-333333333333',
    5.0,
    'Kabir did an unbelievable drone shoot for our Bengaluru estate. The 4K footage was silky smooth.',
    'Sunil Hegde',
    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&q=80'
)
ON CONFLICT (id) DO NOTHING;
