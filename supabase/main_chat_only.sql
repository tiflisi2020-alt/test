-- საერთო ჩატი — ცალკე გაშვება, თუ all_departments.sql უკვე გაქვთ გაშვებული ძველი ვერსიით.
-- Dashboard → SQL Editor → Run

CREATE TABLE IF NOT EXISTS public.main_chat_messages (
  id          bigserial PRIMARY KEY,
  author      text NOT NULL DEFAULT '',
  body        text NOT NULL CHECK (char_length(trim(body)) > 0 AND char_length(body) <= 800),
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS main_chat_messages_created_at_idx
  ON public.main_chat_messages (created_at DESC);

ALTER TABLE public.main_chat_messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS schedule_full_access ON public.main_chat_messages;
CREATE POLICY schedule_full_access ON public.main_chat_messages FOR ALL USING (true) WITH CHECK (true);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.main_chat_messages TO anon, authenticated;

DO $$
DECLARE seqreg text;
BEGIN
  seqreg := pg_get_serial_sequence('public.main_chat_messages', 'id');
  IF seqreg IS NOT NULL THEN
    EXECUTE format('GRANT USAGE, SELECT ON SEQUENCE %s TO anon, authenticated', seqreg);
  END IF;
END $$;
