-- ═══════════════════════════════════════════════════════════════════════════
-- Supabase smoke test (SQL Editor → New query → Run)
-- Uses sentinel rows __TEST_*__ — safe to re-run; uncomment cleanup at bottom to remove.
-- ═══════════════════════════════════════════════════════════════════════════

-- ── 1) Tables exist + row counts ────────────────────────────────────────────
SELECT 'waiters'            AS tbl, COUNT(*)::int AS n FROM public.waiters
UNION ALL SELECT 'waiter_positions', COUNT(*)::int FROM public.waiter_positions
UNION ALL SELECT 'chefs', COUNT(*)::int FROM public.chefs
UNION ALL SELECT 'chef_positions', COUNT(*)::int FROM public.chef_positions
UNION ALL SELECT 'cleaners', COUNT(*)::int FROM public.cleaners
UNION ALL SELECT 'cleaner_positions', COUNT(*)::int FROM public.cleaner_positions
UNION ALL SELECT 'cashiers', COUNT(*)::int FROM public.cashiers
UNION ALL SELECT 'cashier_positions', COUNT(*)::int FROM public.cashier_positions
UNION ALL SELECT 'hostesses', COUNT(*)::int FROM public.hostesses
UNION ALL SELECT 'hostess_positions', COUNT(*)::int FROM public.hostess_positions
UNION ALL SELECT 'main_chat_messages', COUNT(*)::int FROM public.main_chat_messages
ORDER BY tbl;

-- ── 2) Hostess: insert person + one shift (matches app shape) ─────────────
DELETE FROM public.hostess_positions WHERE hostess_name = '__TEST_HOSTESS__';
DELETE FROM public.hostesses WHERE name = '__TEST_HOSTESS__';

INSERT INTO public.hostesses (name, phone, position_order)
VALUES ('__TEST_HOSTESS__', '555 000 000', 999)
RETURNING id, name, phone, position_order;

INSERT INTO public.hostess_positions (hostess_name, shift_date, shift_time, notes)
VALUES (
  '__TEST_HOSTESS__',
  CURRENT_DATE,
  '14:00–00:00',
  'SQL smoke test'
)
RETURNING hostess_name, shift_date, shift_time, notes;

-- Should return 1 row
SELECT * FROM public.hostess_positions
WHERE hostess_name = '__TEST_HOSTESS__' AND shift_date = CURRENT_DATE;

-- ── 3) Waiter: insert + position (has position column) ─────────────────────
DELETE FROM public.waiter_positions WHERE waiter_name = '__TEST_WAITER__';
DELETE FROM public.waiters WHERE name = '__TEST_WAITER__';

INSERT INTO public.waiters (name, phone, position_order)
VALUES ('__TEST_WAITER__', '555 000 001', 999)
RETURNING id, name;

INSERT INTO public.waiter_positions (waiter_name, shift_date, shift_time, position, notes)
VALUES (
  '__TEST_WAITER__',
  CURRENT_DATE,
  '10:00–18:00',
  NULL,
  'SQL smoke test'
)
RETURNING waiter_name, shift_date, shift_time;

SELECT * FROM public.waiter_positions
WHERE waiter_name = '__TEST_WAITER__' AND shift_date = CURRENT_DATE;

-- ── 4) Main chat (optional) ───────────────────────────────────────────────
INSERT INTO public.main_chat_messages (author, body)
VALUES ('__TEST__', 'smoke test message')
RETURNING id, author, left(body, 40) AS body_preview, created_at;

-- ── 5) Cleanup (uncomment to delete test rows) ────────────────────────────
-- DELETE FROM public.hostess_positions WHERE hostess_name = '__TEST_HOSTESS__';
-- DELETE FROM public.hostesses WHERE name = '__TEST_HOSTESS__';
-- DELETE FROM public.waiter_positions WHERE waiter_name = '__TEST_WAITER__';
-- DELETE FROM public.waiters WHERE name = '__TEST_WAITER__';
-- DELETE FROM public.main_chat_messages WHERE author = '__TEST__';
