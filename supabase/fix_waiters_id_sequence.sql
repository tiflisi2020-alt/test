-- ═══════════════════════════════════════════════════════════════════════════
-- public.waiters — id სვეტის გასწორება
--
-- შენი ცხრილი: id = UUID (არა serial). ამიტომ წინა სკრიპტი (MAX(id), sequence)
-- ვერ იმუშავებს.
--
-- 1) თუ წინა მცდელობით შეიქმნა waiters_id_seq — წავშალოთ (არ გჭირდება UUID-ზე)
-- 2) INSERT-ისას id თვითონ შეივსოს: DEFAULT gen_random_uuid()
--
-- PostgreSQL 13+ / Supabase: gen_random_uuid() ჩაშენებულია.
-- ═══════════════════════════════════════════════════════════════════════════

DROP SEQUENCE IF EXISTS public.waiters_id_seq;

ALTER TABLE public.waiters
  ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- შემოწმება (სურვილისამებრ):
-- SELECT column_default FROM information_schema.columns
-- WHERE table_schema = 'public' AND table_name = 'waiters' AND column_name = 'id';
