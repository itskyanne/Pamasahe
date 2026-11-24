-- =============================================================================
-- PAMASAHE: DAVAO CITY COMMUTER COMPANION & FARE TRACKER
-- Supabase PostgreSQL Cloud Database Schema & Row-Level Security (RLS)
-- CCE 106 - Mobile Application Development
-- =============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. COMMUTER USER PROFILES
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL DEFAULT 'Student Commuter',
    subtitle TEXT DEFAULT 'Student commuter · Member since 2026',
    avatar_url TEXT,
    concession_type TEXT NOT NULL DEFAULT 'student', -- 'none', 'student', 'senior', 'pwd'
    weekly_budget NUMERIC(10, 2) NOT NULL DEFAULT 150.00,
    monthly_budget NUMERIC(10, 2) NOT NULL DEFAULT 600.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. SAVED COMMUTE PLACES & ANCHORS
CREATE TABLE IF NOT EXISTS public.saved_places (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    address TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'Home', -- 'Home', 'School', 'Mall', 'Terminal', 'Other'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. PERSONAL COMMUTE ROUTES
CREATE TABLE IF NOT EXISTS public.commute_routes (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    from_place TEXT NOT NULL,
    to_place TEXT NOT NULL,
    travel_minutes INTEGER DEFAULT 30,
    fares_updated_at TEXT NOT NULL DEFAULT to_char(now(), 'Mon DD, YYYY'),
    is_community_shared BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. ROUTE TRANSIT LEGS / STEPS
CREATE TABLE IF NOT EXISTS public.route_steps (
    id BIGSERIAL PRIMARY KEY,
    route_id BIGINT REFERENCES public.commute_routes(id) ON DELETE CASCADE NOT NULL,
    step_order INTEGER NOT NULL,
    ride_type TEXT NOT NULL, -- 'Jeepney', 'Modern PUV', 'Bus', 'Tricycle', 'UV Express', 'Walking'
    boarding_point TEXT NOT NULL,
    fare NUMERIC(10, 2) NOT NULL DEFAULT 13.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 5. HISTORICAL TRIP EXPENSE LEDGER (Copy-on-write isolation)
CREATE TABLE IF NOT EXISTS public.trip_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    route_id BIGINT REFERENCES public.commute_routes(id) ON DELETE SET NULL,
    route_name TEXT NOT NULL,
    trip_date TEXT NOT NULL,
    amount_paid NUMERIC(10, 2) NOT NULL,
    vehicle_type TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 6. COMMUNITY SHARED ROUTES (Feature Upgrade 2)
CREATE TABLE IF NOT EXISTS public.community_routes (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    from_place TEXT NOT NULL,
    to_place TEXT NOT NULL,
    travel_minutes INTEGER NOT NULL DEFAULT 40,
    author_name TEXT NOT NULL DEFAULT 'Anonymous Student',
    likes_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.community_route_steps (
    id BIGSERIAL PRIMARY KEY,
    community_route_id BIGINT REFERENCES public.community_routes(id) ON DELETE CASCADE NOT NULL,
    step_order INTEGER NOT NULL,
    ride_type TEXT NOT NULL,
    boarding_point TEXT NOT NULL,
    fare NUMERIC(10, 2) NOT NULL
);

-- 7. OVER-THE-AIR (OTA) DAVAO TRANSIT LINES CATALOG (Feature Upgrade 3)
CREATE TABLE IF NOT EXISTS public.transit_lines_ota (
    id BIGSERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    ride_type TEXT NOT NULL,
    route_coverage TEXT NOT NULL,
    base_fare NUMERIC(10, 2) NOT NULL,
    per_km_rate NUMERIC(10, 2) NOT NULL DEFAULT 1.80,
    frequency_minutes INTEGER NOT NULL DEFAULT 8,
    first_trip TEXT NOT NULL DEFAULT '05:00 AM',
    last_trip TEXT NOT NULL DEFAULT '10:30 PM',
    is_loop BOOLEAN DEFAULT FALSE,
    stops JSONB NOT NULL DEFAULT '[]'::jsonb,
    matrix_version TEXT NOT NULL DEFAULT 'LTFRB-2026.11',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- =============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =============================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_places ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.commute_routes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.route_steps ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trip_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_routes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_route_steps ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transit_lines_ota ENABLE ROW LEVEL SECURITY;

-- Profiles: Users can view and update their own profile
CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Saved Places: Isolated per user
CREATE POLICY "Users manage own places" ON public.saved_places FOR ALL USING (auth.uid() = user_id);

-- Routes & Steps: Isolated per user
CREATE POLICY "Users manage own routes" ON public.commute_routes FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users manage own steps" ON public.route_steps FOR ALL USING (
    EXISTS (SELECT 1 FROM public.commute_routes WHERE public.commute_routes.id = route_steps.route_id AND public.commute_routes.user_id = auth.uid())
);

-- Trip Logs: Isolated per user
CREATE POLICY "Users manage own trip logs" ON public.trip_logs FOR ALL USING (auth.uid() = user_id);

-- Community Routes: Anyone authenticated or anonymous can read; users can insert
CREATE POLICY "Public read for community routes" ON public.community_routes FOR SELECT USING (true);
CREATE POLICY "Authenticated users can publish community routes" ON public.community_routes FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Public read for community route steps" ON public.community_route_steps FOR SELECT USING (true);

-- Transit Lines OTA: Public read for all commuters
CREATE POLICY "Public read for official OTA transit lines" ON public.transit_lines_ota FOR SELECT USING (true);

-- =============================================================================
-- INITIAL SEED DATA: OFFICIAL DAVAO CITY TRANSIT LINES
-- =============================================================================

INSERT INTO public.transit_lines_ota (code, name, ride_type, route_coverage, base_fare, per_km_rate, stops, matrix_version)
VALUES
('J02', 'Route 02: Matina – Downtown Poblacion', 'Jeepney', 'Ulas -> Matina -> Bankerohan -> San Pedro -> CM Recto', 13.00, 1.80, '["Ulas", "Matina Crossing", "Bankerohan Public Market", "Davao City Hall", "San Pedro St"]'::jsonb, 'LTFRB-2026.11'),
('B08', 'Route 08: Toril Express – Roxas Night Market', 'Modern PUV', 'Toril Central -> Puan -> Bangkal -> Matina -> Roxas Ave', 15.00, 2.20, '["Toril Terminal", "Puan Crossing", "Bangkal Market", "Matina Overpass", "Roxas Night Market"]'::jsonb, 'LTFRB-2026.11'),
('J04', 'Route 04: Buhangin – City Hall via Bajada', 'Jeepney', 'Buhangin Milan -> Victoria Plaza -> Abreeza -> Post Office', 13.00, 1.80, '["Buhangin Milan", "Ladislawa", "Bajada Abreeza", "San Pedro", "City Hall"]'::jsonb, 'LTFRB-2026.11')
ON CONFLICT (code) DO NOTHING;
