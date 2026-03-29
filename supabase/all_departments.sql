-- ═══════════════════════════════════════════════════════════════════════════
-- Restaurant Tiflisi — ყველა განყოფილების ცხრილები Supabase-ში
-- გაუშვი: Dashboard → SQL Editor → New query → Paste → Run
--
-- PGRST205 = "Could not find the table in the schema cache"
--   → ცხრილი არ არსებობს ან PostgREST-მა ჯერ ვერ დაინახა.
--   შექმნის შემდეგ: Settings → API → "Reload schema" (ან 1–2 წუთი დაელოდე).
-- ═══════════════════════════════════════════════════════════════════════════

-- ── 1) მიმტანები ───────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.waiters (
  id              serial PRIMARY KEY,
  name            text NOT NULL,
  phone           text,
  position_order  int NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS public.waiter_positions (
  waiter_name  text NOT NULL,
  shift_date   date NOT NULL,
  shift_time   text,
  position     text,
  notes        text,
  PRIMARY KEY (waiter_name, shift_date)
);

-- ── 2) მზარეულები ──────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.chefs (
  id              serial PRIMARY KEY,
  name            text NOT NULL,
  phone           text,
  position_order  int NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS public.chef_positions (
  chef_name   text NOT NULL,
  shift_date  date NOT NULL,
  shift_time  text,
  notes       text,
  PRIMARY KEY (chef_name, shift_date)
);

-- ── 3) დალაგება / დასუფთავება ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.cleaners (
  id              serial PRIMARY KEY,
  name            text NOT NULL,
  phone           text,
  position_order  int NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS public.cleaner_positions (
  cleaner_name  text NOT NULL,
  shift_date    date NOT NULL,
  shift_time    text,
  notes         text,
  PRIMARY KEY (cleaner_name, shift_date)
);

-- ── 4) მოლარეები ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.cashiers (
  id              serial PRIMARY KEY,
  name            text NOT NULL,
  phone           text,
  position_order  int NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS public.cashier_positions (
  cashier_name  text NOT NULL,
  shift_date    date NOT NULL,
  shift_time    text,
  notes         text,
  PRIMARY KEY (cashier_name, shift_date)
);

-- ── 5) ჰოსტესები ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.hostesses (
  id              serial PRIMARY KEY,
  name            text NOT NULL,
  phone           text,
  position_order  int NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS public.hostess_positions (
  hostess_name  text NOT NULL,
  shift_date    date NOT NULL,
  shift_time    text,
  notes         text,
  PRIMARY KEY (hostess_name, shift_date)
);

-- ── საერთო ჩატი (მთავარი გვერდი) ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.main_chat_messages (
  id          bigserial PRIMARY KEY,
  author      text NOT NULL DEFAULT '',
  body        text NOT NULL CHECK (char_length(trim(body)) > 0 AND char_length(body) <= 800),
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS main_chat_messages_created_at_idx
  ON public.main_chat_messages (created_at DESC);

-- ── ადმინის პარამეტრები (ცვლების სია, შეტყობინება, თემა) — სინქრონი მოწყობილობებს შორის
CREATE TABLE IF NOT EXISTS public.app_settings (
  key         text PRIMARY KEY,
  value       jsonb NOT NULL,
  updated_at  timestamptz NOT NULL DEFAULT now()
);

-- ═══════════════════════════════════════════════════════════════════════════
-- RLS (იგივე ლოგიკა ყველა ცხრილზე: anon + authenticated — სრული წვდომა)
-- ⚠️ საჯარო anon key-ით ეს ყველას წვდომას იძლევა. პროდაქშენში გამოიყენე მკაცრი პოლიტიკა.
-- ═══════════════════════════════════════════════════════════════════════════

ALTER TABLE public.waiters            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.waiter_positions   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chefs              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chef_positions     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cleaners           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cleaner_positions  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cashiers           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cashier_positions  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hostesses          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hostess_positions  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.main_chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_settings         ENABLE ROW LEVEL SECURITY;

-- პოლიტიკა: ყველა როლს (მათ შორის anon — ბრაუზერიდან API key-ით)
-- იგივე სახელი ცხრილზე ცალ-ცალკე დასაშვებაა
DROP POLICY IF EXISTS schedule_full_access ON public.waiters;
CREATE POLICY schedule_full_access ON public.waiters FOR ALL USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS schedule_full_access ON public.waiter_positions;
CREATE POLICY schedule_full_access ON public.waiter_positions FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS schedule_full_access ON public.chefs;
CREATE POLICY schedule_full_access ON public.chefs FOR ALL USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS schedule_full_access ON public.chef_positions;
CREATE POLICY schedule_full_access ON public.chef_positions FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS schedule_full_access ON public.cleaners;
CREATE POLICY schedule_full_access ON public.cleaners FOR ALL USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS schedule_full_access ON public.cleaner_positions;
CREATE POLICY schedule_full_access ON public.cleaner_positions FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS schedule_full_access ON public.cashiers;
CREATE POLICY schedule_full_access ON public.cashiers FOR ALL USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS schedule_full_access ON public.cashier_positions;
CREATE POLICY schedule_full_access ON public.cashier_positions FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS schedule_full_access ON public.hostesses;
CREATE POLICY schedule_full_access ON public.hostesses FOR ALL USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS schedule_full_access ON public.hostess_positions;
CREATE POLICY schedule_full_access ON public.hostess_positions FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS schedule_full_access ON public.main_chat_messages;
CREATE POLICY schedule_full_access ON public.main_chat_messages FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS schedule_full_access ON public.app_settings;
CREATE POLICY schedule_full_access ON public.app_settings FOR ALL USING (true) WITH CHECK (true);

-- API როლებს მხოლოდ ამ ცხრილებზე
GRANT SELECT, INSERT, UPDATE, DELETE ON public.waiters TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.waiter_positions TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.chefs TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.chef_positions TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.cleaners TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.cleaner_positions TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.cashiers TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.cashier_positions TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.hostesses TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.hostess_positions TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.main_chat_messages TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.app_settings TO anon, authenticated;

-- Sequence-ების სახელები შეიძლება განსხვავდებოდეს (ძველი ცხრილი, identity, სხვა სქემა).
-- GRANT მხოლოდ მაშინ, როცა pg_get_serial_sequence იპოვის ბმულს id სვეტზე.
DO $$
DECLARE
  tbl text;
  seqreg text;
  tables text[] := ARRAY['waiters','chefs','cleaners','cashiers','hostesses'];
BEGIN
  FOREACH tbl IN ARRAY tables
  LOOP
    seqreg := pg_get_serial_sequence(format('public.%I', tbl), 'id');
    IF seqreg IS NOT NULL THEN
      EXECUTE format('GRANT USAGE, SELECT ON SEQUENCE %s TO anon, authenticated', seqreg);
    END IF;
  END LOOP;
  seqreg := pg_get_serial_sequence('public.main_chat_messages', 'id');
  IF seqreg IS NOT NULL THEN
    EXECUTE format('GRANT USAGE, SELECT ON SEQUENCE %s TO anon, authenticated', seqreg);
  END IF;
END $$;
