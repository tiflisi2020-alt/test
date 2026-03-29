-- ═══════════════════════════════════════════════════════════════════════════
-- Restaurant Tiflisi — Supabase დიაგნოსტიკა (SQL Editor → New query → Run)
--
-- რას ამოწმებს: ცხრილები, სვეტები, RLS, პოლიტიკა schedule_full_access,
--              anon/authenticated GRANT-ები, serial/bigserial sequence-ებზე USAGE.
--
-- შედეგი: ცხრილი severity, category, item, detail
--   • ERROR — უნდა გამოასწორო (ცხრილი/სვეტი აკლია, RLS ჩართულია მაგრამ პოლიტიკა არა, და ა.შ.)
--   • WARN  — სავარაუდოდ პრობლემა (მაგ. RLS გამორთული)
--   • OK    — რიგი სწორია
--
-- გაგზავნე მთელი შედეგის ტექსტი (Copy rows / Export CSV) ჩატში ანალიზისთვის.
--
-- ⚠️  უნდა გაუშვა მთელი ფაილი ერთად. პირველი სიტყვა სავალდებულოა: WITH
--     თუ მხოლოდ ნაწილს ჩასვამ, მიიღებ: syntax error at or near "chk_..."
-- ═══════════════════════════════════════════════════════════════════════════

WITH
tables_expected AS (
  SELECT unnest(ARRAY[
    'waiters','waiter_positions','chefs','chef_positions','cleaners','cleaner_positions',
    'cashiers','cashier_positions','hostesses','hostess_positions',
    'main_chat_messages','app_settings'
  ]::text[]) AS tbl
),
chk_tables AS (
  SELECT
    CASE WHEN c.oid IS NULL THEN 'ERROR' ELSE 'OK' END AS severity,
    'table_exists'::text AS category,
    t.tbl AS item,
    CASE WHEN c.oid IS NULL
      THEN 'ცხრილი public.' || t.tbl || ' არ არსებობს — გაუშვი supabase/all_departments.sql'
      ELSE 'OK'
    END AS detail
  FROM tables_expected t
  LEFT JOIN pg_class c ON c.relname = t.tbl AND c.relnamespace = 'public'::regnamespace AND c.relkind = 'r'
),
cols AS (
  SELECT * FROM (VALUES
    ('waiters', 'id'), ('waiters', 'name'), ('waiters', 'phone'), ('waiters', 'position_order'),
    ('waiter_positions', 'waiter_name'), ('waiter_positions', 'shift_date'), ('waiter_positions', 'shift_time'),
    ('waiter_positions', 'position'), ('waiter_positions', 'notes'),
    ('chefs', 'id'), ('chefs', 'name'), ('chefs', 'phone'), ('chefs', 'position_order'),
    ('chef_positions', 'chef_name'), ('chef_positions', 'shift_date'), ('chef_positions', 'shift_time'), ('chef_positions', 'notes'),
    ('cleaners', 'id'), ('cleaners', 'name'), ('cleaners', 'phone'), ('cleaners', 'position_order'),
    ('cleaner_positions', 'cleaner_name'), ('cleaner_positions', 'shift_date'), ('cleaner_positions', 'shift_time'), ('cleaner_positions', 'notes'),
    ('cashiers', 'id'), ('cashiers', 'name'), ('cashiers', 'phone'), ('cashiers', 'position_order'),
    ('cashier_positions', 'cashier_name'), ('cashier_positions', 'shift_date'), ('cashier_positions', 'shift_time'), ('cashier_positions', 'notes'),
    ('hostesses', 'id'), ('hostesses', 'name'), ('hostesses', 'phone'), ('hostesses', 'position_order'),
    ('hostess_positions', 'hostess_name'), ('hostess_positions', 'shift_date'), ('hostess_positions', 'shift_time'), ('hostess_positions', 'notes'),
    ('main_chat_messages', 'id'), ('main_chat_messages', 'author'), ('main_chat_messages', 'body'), ('main_chat_messages', 'created_at'),
    ('app_settings', 'key'), ('app_settings', 'value'), ('app_settings', 'updated_at')
  ) AS v(tbl, col)
),
chk_columns AS (
  SELECT
    CASE WHEN ic.column_name IS NULL THEN 'ERROR' ELSE 'OK' END AS severity,
    'column_exists'::text AS category,
    c.tbl || '.' || c.col AS item,
    CASE WHEN ic.column_name IS NULL
      THEN 'სვეტი აკლია — შეადარე all_departments.sql (ან ALTER TABLE)'
      ELSE 'OK'
    END AS detail
  FROM cols c
  LEFT JOIN information_schema.columns ic
    ON ic.table_schema = 'public' AND ic.table_name = c.tbl AND ic.column_name = c.col
),
chk_rls AS (
  SELECT
    CASE
      WHEN c.oid IS NULL THEN 'ERROR'
      WHEN NOT c.relrowsecurity THEN 'WARN'
      ELSE 'OK'
    END AS severity,
    'rls_enabled'::text AS category,
    t.tbl AS item,
    CASE
      WHEN c.oid IS NULL THEN 'ცხრილი არ არსებობს'
      WHEN NOT c.relrowsecurity THEN 'RLS გამორთულია — ALTER TABLE ... ENABLE ROW LEVEL SECURITY'
      ELSE 'OK'
    END AS detail
  FROM tables_expected t
  LEFT JOIN pg_class c ON c.relname = t.tbl AND c.relnamespace = 'public'::regnamespace AND c.relkind = 'r'
),
chk_policies AS (
  SELECT
    CASE
      WHEN c.oid IS NULL THEN 'ERROR'
      WHEN c.relrowsecurity AND p.policyname IS NULL THEN 'ERROR'
      WHEN NOT c.relrowsecurity THEN 'OK'
      ELSE 'OK'
    END AS severity,
    'policy_schedule_full_access'::text AS category,
    t.tbl AS item,
    CASE
      WHEN c.oid IS NULL THEN 'ცხრილი არ არსებობს'
      WHEN c.relrowsecurity AND p.policyname IS NULL
        THEN 'RLS ჩართულია, მაგრამ პოლიტიკა schedule_full_access არ ჩანს — გაუშვი all_departments.sql პოლიტიკის ბლოკი'
      WHEN NOT c.relrowsecurity THEN 'OK (RLS გამორთული — პოლიტიკა არ არის სავალდებულო)'
      ELSE 'OK'
    END AS detail
  FROM tables_expected t
  LEFT JOIN pg_class c ON c.relname = t.tbl AND c.relnamespace = 'public'::regnamespace AND c.relkind = 'r'
  LEFT JOIN pg_policies p ON p.schemaname = 'public' AND p.tablename = t.tbl AND p.policyname = 'schedule_full_access'
),
chk_grant_anon AS (
  SELECT
    CASE
      WHEN c.oid IS NULL THEN 'ERROR'
      WHEN NOT has_table_privilege('anon', format('public.%I', t.tbl)::regclass, 'SELECT') THEN 'ERROR'
      WHEN NOT has_table_privilege('anon', format('public.%I', t.tbl)::regclass, 'INSERT') THEN 'WARN'
      ELSE 'OK'
    END AS severity,
    'grant_anon'::text AS category,
    t.tbl AS item,
    CASE
      WHEN c.oid IS NULL THEN 'ცხრილი არ არსებობს'
      WHEN NOT has_table_privilege('anon', format('public.%I', t.tbl)::regclass, 'SELECT')
        THEN 'anon-ს არ აქვს SELECT — დაამატე GRANT სქემაში'
      WHEN NOT has_table_privilege('anon', format('public.%I', t.tbl)::regclass, 'INSERT')
        THEN 'anon-ს არ აქვს INSERT (აპი ვერ ჩაწერს)'
      ELSE 'OK (SELECT+INSERT anon-ზე)'
    END AS detail
  FROM tables_expected t
  LEFT JOIN pg_class c ON c.relname = t.tbl AND c.relnamespace = 'public'::regnamespace AND c.relkind = 'r'
),
chk_grant_auth AS (
  SELECT
    CASE
      WHEN c.oid IS NULL THEN 'ERROR'
      WHEN NOT has_table_privilege('authenticated', format('public.%I', t.tbl)::regclass, 'SELECT') THEN 'WARN'
      ELSE 'OK'
    END AS severity,
    'grant_authenticated'::text AS category,
    t.tbl AS item,
    CASE
      WHEN c.oid IS NULL THEN 'ცხრილი არ არსებობს'
      WHEN NOT has_table_privilege('authenticated', format('public.%I', t.tbl)::regclass, 'SELECT')
        THEN 'authenticated-ს არ აქვს SELECT'
      ELSE 'OK'
    END AS detail
  FROM tables_expected t
  LEFT JOIN pg_class c ON c.relname = t.tbl AND c.relnamespace = 'public'::regnamespace AND c.relkind = 'r'
),
serial_tables AS (
  SELECT unnest(ARRAY[
    'waiters','chefs','cleaners','cashiers','hostesses','main_chat_messages'
  ]::text[]) AS tbl
),
chk_seq AS (
  SELECT
    CASE
      WHEN c.oid IS NULL THEN 'ERROR'
      WHEN idcol.column_name IS NULL THEN 'ERROR'
      WHEN idcol.data_type = 'uuid' THEN 'OK'
      WHEN sn.nspname IS NULL THEN 'WARN'
      WHEN NOT has_sequence_privilege('anon', format('%I.%I', sn.nspname, s.relname)::regclass, 'USAGE') THEN 'ERROR'
      ELSE 'OK'
    END AS severity,
    'sequence_anon_usage'::text AS category,
    st.tbl || ' (id)' AS item,
    CASE
      WHEN c.oid IS NULL THEN 'ცხრილი არ არსებობს'
      WHEN idcol.column_name IS NULL THEN 'სვეტი id აკლია ცხრილს'
      WHEN idcol.data_type = 'uuid'
        THEN 'OK — id არის UUID; serial sequence არ გამოიყენება (გამოიყენე gen_random_uuid() DEFAULT თუ საჭიროა)'
      WHEN sn.nspname IS NULL THEN 'serial/bigserial sequence ვერ მოიძებნა id-ზე (integer/bigint id-სთვის იხ. fix_waiters_id_sequence.sql ან all_departments.sql)'
      WHEN NOT has_sequence_privilege('anon', format('%I.%I', sn.nspname, s.relname)::regclass, 'USAGE')
        THEN 'anon-ს არ აქვს USAGE sequence-ზე — INSERT id DEFAULT ვერ იმუშავებს; გაუშვი all_departments.sql GRANT ბლოკი'
      ELSE 'OK'
    END AS detail
  FROM serial_tables st
  LEFT JOIN pg_class c ON c.relname = st.tbl AND c.relnamespace = 'public'::regnamespace AND c.relkind = 'r'
  LEFT JOIN information_schema.columns idcol
    ON idcol.table_schema = 'public' AND idcol.table_name = st.tbl AND idcol.column_name = 'id'
  LEFT JOIN LATERAL (
    SELECT pg_get_serial_sequence(format('public.%I', st.tbl), 'id') AS seq_fqn
  ) sq ON idcol.data_type IS DISTINCT FROM 'uuid'
  LEFT JOIN pg_class s ON sq.seq_fqn IS NOT NULL AND s.oid = sq.seq_fqn::regclass
  LEFT JOIN pg_namespace sn ON sn.oid = s.relnamespace
),
chk_index_chat AS (
  SELECT
    CASE
      WHEN c.oid IS NULL THEN 'ERROR'
      WHEN NOT EXISTS (
        SELECT 1 FROM pg_indexes
        WHERE schemaname = 'public' AND tablename = 'main_chat_messages'
          AND indexname = 'main_chat_messages_created_at_idx'
      ) THEN 'WARN'
      ELSE 'OK'
    END AS severity,
    'index'::text AS category,
    'main_chat_messages_created_at_idx'::text AS item,
    CASE
      WHEN c.oid IS NULL THEN 'ცხრილი არ არსებობს'
      WHEN NOT EXISTS (
        SELECT 1 FROM pg_indexes
        WHERE schemaname = 'public' AND tablename = 'main_chat_messages'
          AND indexname = 'main_chat_messages_created_at_idx'
      ) THEN 'ინდექსი რეკომენდებულია (ჩატის სორტირება) — main_chat_only.sql'
      ELSE 'OK'
    END AS detail
  FROM (VALUES ('main_chat_messages')) AS v(tbl)
  LEFT JOIN pg_class c
    ON c.relname = v.tbl AND c.relnamespace = 'public'::regnamespace AND c.relkind = 'r'
),
all_rows AS (
  SELECT * FROM chk_tables
  UNION ALL SELECT * FROM chk_columns
  UNION ALL SELECT * FROM chk_rls
  UNION ALL SELECT * FROM chk_policies
  UNION ALL SELECT * FROM chk_grant_anon
  UNION ALL SELECT * FROM chk_grant_auth
  UNION ALL SELECT * FROM chk_seq
  UNION ALL SELECT * FROM chk_index_chat
)
SELECT severity, category, item, detail
FROM all_rows
ORDER BY
  CASE severity WHEN 'ERROR' THEN 1 WHEN 'WARN' THEN 2 ELSE 3 END,
  category,
  item;
