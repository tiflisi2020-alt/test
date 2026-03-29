-- თუ all_departments.sql უკვე გაქვს გაშვებული, მხოლოდ ეს ბლოკი დაამატე (ან გაუშვი ცალკე).
CREATE TABLE IF NOT EXISTS public.app_settings (
  key         text PRIMARY KEY,
  value       jsonb NOT NULL,
  updated_at  timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS schedule_full_access ON public.app_settings;
CREATE POLICY schedule_full_access ON public.app_settings FOR ALL USING (true) WITH CHECK (true);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.app_settings TO anon, authenticated;
