-- ==============================================================================
-- PYP (Pick Your Photographer) - Supabase Complete Seed Script
-- Run this in your Supabase SQL Editor to populate verified creators, packages, and reviews!
-- ==============================================================================

-- 1. Ensure Table Schema and Permissive Policies for Demo/Client Access
ALTER TABLE IF EXISTS public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.photographers ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.deliverables ENABLE ROW LEVEL SECURITY;

-- Permissive RLS Policies
DROP POLICY IF EXISTS "Public read users" ON public.users;
CREATE POLICY "Public read users" ON public.users FOR SELECT USING (true);
DROP POLICY IF EXISTS "Public insert users" ON public.users;
CREATE POLICY "Public insert users" ON public.users FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Public update users" ON public.users;
CREATE POLICY "Public update users" ON public.users FOR UPDATE USING (true);

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

-- 2. Populate 6 Top Verified Photographers
INSERT INTO public.photographers (id, name, bio, tagline, avatar_url, cover_url, location, latitude, longitude, rating, review_count, starting_price, is_verified, is_available, categories, styles, equipment, experience_years, portfolio_images)
VALUES
(
    'a1111111-1111-1111-1111-111111111111',
    'Arjun Mehta',
    'Award-winning celebrity and high-fashion editorial photographer with 8+ years experience in Mumbai & Paris.',
    'Vogue Featured • Cinematic Light Specialist',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&q=80',
    'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=1200&q=80',
    'Bandra West, Mumbai',
    19.0596,
    72.8295,
    4.95,
    128,
    4999.00,
    TRUE,
    TRUE,
    ARRAY['Wedding', 'Portrait', 'Fashion', 'Editorial'],
    ARRAY['Cinematic', 'Editorial', 'Moody & Dark', 'Vibrant & Warm'],
    ARRAY['Sony A7 IV', '85mm f/1.4 GM', '50mm f/1.2 GM', 'Profoto B10 Plus'],
    8,
    ARRAY[
        'https://images.unsplash.com/photo-1519741497674-611481863552?w=800&q=80',
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80',
        'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=800&q=80'
    ]
),
(
    'a2222222-2222-2222-2222-222222222222',
    'Priya Sharma',
    'Specializing in royal Indian destination weddings, candid emotional moments, and heirloom visual stories with 6+ years experience.',
    'Luxury Destination Wedding & Candid Storyteller',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=500&q=80',
    'https://images.unsplash.com/photo-1519741497674-611481863552?w=1200&q=80',
    'South Delhi & Jaipur',
    28.5355,
    77.2625,
    4.98,
    214,
    8999.00,
    TRUE,
    TRUE,
    ARRAY['Wedding', 'Pre-Wedding', 'Candid', 'Event'],
    ARRAY['Vibrant & Warm', 'Natural & Airy', 'Traditional Indian'],
    ARRAY['Canon EOS R5', '70-200mm f/2.8L IS', '28-70mm f/2.0L', 'Godox AD400 Pro'],
    6,
    ARRAY[
        'https://images.unsplash.com/photo-1583939003579-730e3918a45a?w=800&q=80',
        'https://images.unsplash.com/photo-1606800052052-a08af7148866?w=800&q=80'
    ]
),
(
    'a3333333-3333-3333-3333-333333333333',
    'Kabir Sen',
    'DGCA Certified commercial drone pilot and aerial cinematographer capturing breathtaking 4K perspectives for real estate and luxury brands.',
    'DGCA Certified 4K Aerial & Drone Specialist',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&q=80',
    'https://images.unsplash.com/photo-1508614589041-895b88991e3e?w=1200&q=80',
    'Indiranagar, Bangalore',
    12.9784,
    77.6408,
    4.88,
    92,
    3499.00,
    TRUE,
    TRUE,
    ARRAY['Drone', 'Aerial', 'Real Estate', 'Event', 'Commercial'],
    ARRAY['Cinematic', 'Landscape', 'High Dynamic Range'],
    ARRAY['DJI Inspire 3', 'DJI Mavic 3 Pro Cine', 'Sony FX3', 'Master Wheels'],
    5,
    ARRAY[
        'https://images.unsplash.com/photo-1508614589041-895b88991e3e?w=800&q=80',
        'https://images.unsplash.com/photo-1527977966376-1c8408f9f108?w=800&q=80'
    ]
),
(
    'a4444444-4444-4444-4444-444444444444',
    'Rohan Verma',
    'Fast-paced viral content creator, cinematic colorist, and 4K vertical reels director crafting high-converting visual assets.',
    '4K Viral Reels & High-Fashion Video Director',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&q=80',
    'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=1200&q=80',
    'Anjuna, Goa & Mumbai',
    15.5733,
    73.7410,
    4.92,
    156,
    5999.00,
    TRUE,
    TRUE,
    ARRAY['Reels', 'Fashion', 'Street', 'Portrait'],
    ARRAY['Moody & Dark', 'Cyberpunk', 'High Contrast', 'Vibrant'],
    ARRAY['Sony A7S III', '24-70mm f/2.8 GM II', 'DJI RS 3 Pro Gimbal', 'Aputure 300d'],
    7,
    ARRAY[
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80',
        'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=800&q=80'
    ]
),
(
    'a5555555-5555-5555-5555-555555555555',
    'Aisha Khan',
    'Cherishing newborn wonders, cozy maternity portraits, and heartwarming multigenerational family milestones.',
    'Warm Family, Newborn & Maternity Specialist',
    'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=500&q=80',
    'https://images.unsplash.com/photo-1511895426328-dc8714191300?w=1200&q=80',
    'Jubilee Hills, Hyderabad',
    17.4319,
    78.4073,
    4.91,
    87,
    4499.00,
    TRUE,
    TRUE,
    ARRAY['Maternity', 'Portrait', 'Family', 'Event'],
    ARRAY['Natural & Airy', 'Pastel Minimalist', 'Warm Emotional'],
    ARRAY['Nikon Z8', '50mm f/1.2 S', '105mm f/2.8 Macro', 'Elinchrom Softboxes'],
    6,
    ARRAY[
        'https://images.unsplash.com/photo-1511895426328-dc8714191300?w=800&q=80',
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800&q=80'
    ]
),
(
    'a6666666-6666-6666-6666-666666666666',
    'Vikram Malhotra',
    'Premium corporate headshots, Forbes-style executive branding, and major international summit event photography.',
    'Executive Branding & Global Summit Photographer',
    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=500&q=80',
    'https://images.unsplash.com/photo-1511578314322-379afb476865?w=1200&q=80',
    'BKC, Mumbai',
    19.0657,
    72.8687,
    4.96,
    178,
    6499.00,
    TRUE,
    TRUE,
    ARRAY['Corporate', 'Headshots', 'Event', 'Commercial'],
    ARRAY['Clean High-Key', 'Executive Studio', 'Cinematic Crisp'],
    ARRAY['Canon EOS R3', '85mm f/1.2L DS', '24-70mm f/2.8L', 'Profoto D2 1000W'],
    9,
    ARRAY[
        'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800&q=80',
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=800&q=80'
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

-- 3. Populate Service Packages
INSERT INTO public.packages (id, photographer_id, title, description, duration_hours, price, photos_count, delivery_days, features, is_popular)
VALUES
(
    'b1111111-1111-1111-1111-111111111111',
    'a1111111-1111-1111-1111-111111111111',
    'Standard Essential Shoot',
    'Ideal for portraits, personal branding, and high-fashion social lookbooks.',
    2,
    4999.00,
    30,
    3,
    ARRAY['30 Hand Retouched Master Photos', 'Private Cloud High-Res Gallery', '2 Outfit Changes', '48hr Express Delivery'],
    FALSE
),
(
    'b2222222-2222-2222-2222-222222222222',
    'a1111111-1111-1111-1111-111111111111',
    'Cinematic VIP Editorial',
    'Complete celebrity photoshoot experience with lighting assistant & 4K vertical teaser.',
    4,
    9999.00,
    75,
    5,
    ARRAY['75 Color-Graded RAW & JPEG Deliverables', '2x 4K Ultra-HD Reels Video Cuts', 'Full Studio Lighting Setup Included', 'Unlimited Outfit Changes'],
    TRUE
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
    ARRAY['250+ Master Handcrafted Photos', 'Traditional & Candid Dual Angles', 'Online Client Proofing Portal', 'Heirloom Velvet Photo Album Voucher'],
    TRUE
),
(
    'b4444444-4444-4444-4444-444444444444',
    'a3333333-3333-3333-3333-333333333333',
    'Aerial 4K Drone Master',
    'High-resolution aerial perspectives for architectural estates, resorts, and outdoor events.',
    3,
    5499.00,
    45,
    2,
    ARRAY['45 High-Res 48MP Aerial Photos', '3x Color-Graded 4K Video Clips', 'DGCA Flight Permits Handled', 'Same-Day Fast Cloud Delivery'],
    TRUE
),
(
    'b5555555-5555-5555-5555-555555555555',
    'a4444444-4444-4444-4444-444444444444',
    'Viral Reels Creator Pack',
    '5x Viral-ready 4K vertical reels edited with trending audio sync and color grading.',
    3,
    5999.00,
    40,
    3,
    ARRAY['5x Polished 4K Reels with Subtitles', '40 High-Res Editorial Stills', 'Gimbal Dynamic Motion Tracking', 'Commercial Music Licensing Included'],
    TRUE
)
ON CONFLICT (id) DO UPDATE SET 
    title = EXCLUDED.title,
    price = EXCLUDED.price,
    features = EXCLUDED.features;

-- 4. Populate Reviews
INSERT INTO public.reviews (id, photographer_id, rating, comment, customer_name, customer_avatar)
VALUES
(
    'c1111111-1111-1111-1111-111111111111',
    'a1111111-1111-1111-1111-111111111111',
    5.0,
    'Arjun Mehta is a true master of lighting! He made me feel completely comfortable and the magazine-style portraits exceeded all expectations.',
    'Natasha Verma',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80'
),
(
    'c2222222-2222-2222-2222-222222222222',
    'a1111111-1111-1111-1111-111111111111',
    4.9,
    'Super fast 48h turnaround on the cloud gallery. The tones and depth of the photos are breathtaking. 10/10 recommend!',
    'Rishi Kapoor',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80'
),
(
    'c3333333-3333-3333-3333-333333333333',
    'a3333333-3333-3333-3333-333333333333',
    5.0,
    'Kabir did an unbelievable drone shoot for our Bangalore estate. The 4K footage was silky smooth and razor sharp.',
    'Sunil Hegde',
    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&q=80'
)
ON CONFLICT (id) DO NOTHING;
