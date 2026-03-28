#!/usr/bin/env node
/**
 * REST smoke test against Supabase PostgREST (same paths as the HTML apps).
 *
 * Usage (PowerShell):
 *   $env:SUPABASE_URL="https://YOUR_PROJECT.supabase.co"
 *   $env:SUPABASE_ANON_KEY="eyJ..."
 *   node test/supabase/test_anon_api.mjs
 *
 * Or one line:
 *   $env:SUPABASE_URL="..."; $env:SUPABASE_ANON_KEY="..."; node test/supabase/test_anon_api.mjs
 */

const url = process.env.SUPABASE_URL?.replace(/\/$/, '');
const key = process.env.SUPABASE_ANON_KEY;

if (!url || !key) {
  console.error('Set SUPABASE_URL and SUPABASE_ANON_KEY (Project Settings → API).');
  process.exit(1);
}

const headers = {
  apikey: key,
  Authorization: `Bearer ${key}`,
  'Content-Type': 'application/json',
};

async function get(path) {
  const r = await fetch(`${url}/rest/v1/${path}`, { headers });
  const text = await r.text();
  let body;
  try {
    body = text ? JSON.parse(text) : null;
  } catch {
    body = text;
  }
  return { ok: r.ok, status: r.status, body };
}

async function main() {
  console.log('GET hostesses (limit 3)...');
  console.log(await get('hostesses?select=id,name,phone&order=position_order&limit=3'));

  console.log('\nGET hostess_positions (limit 5)...');
  console.log(await get('hostess_positions?select=hostess_name,shift_date,shift_time&limit=5'));

  console.log('\nGET waiters (limit 3)...');
  console.log(await get('waiters?select=id,name&limit=3'));

  console.log('\nGET main_chat_messages (limit 2, newest)...');
  console.log(
    await get('main_chat_messages?select=id,author,body,created_at&order=created_at.desc&limit=2')
  );

  const allOk =
    (await get('hostesses?select=id&limit=1')).status < 400 &&
    (await get('hostess_positions?select=hostess_name&limit=1')).status < 400;

  console.log(allOk ? '\nDone (endpoints reachable).' : '\nSome requests failed — check RLS/grants/schema.');
  process.exit(allOk ? 0 : 1);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
