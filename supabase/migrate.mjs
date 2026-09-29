// Created: 2026-09-29 14:03:00
// data/data.json → Supabase 1회성 이전 스크립트 (Node 18+ 필요, 외부 패키지 없음)
// [2026-09-29 이전 완료] data/ 폴더는 삭제됨. 다시 쓰려면: git show f0032a9:data/data.json > data/data.json (data 폴더 먼저 생성)
//
// 사용법 (the51-work 폴더에서):
//   PowerShell:
//     $env:SUPABASE_ANON_KEY="<anon public key>"
//     $env:SB_EMAIL="<Supabase Users에 만든 이메일>"
//     $env:SB_PASSWORD="<비밀번호>"
//     node supabase/migrate.mjs            # 실제 이전
//     node supabase/migrate.mjs --dry      # 건수만 확인 (DB 접근 없음)
//
// 몇 번 실행해도 같은 id는 덮어쓰기(upsert)라 중복되지 않습니다.
import { readFileSync } from 'node:fs';

const SB_URL = 'https://cjulprpayqllczddcros.supabase.co';
const DRY = process.argv.includes('--dry');
const src = JSON.parse(readFileSync(new URL('../data/data.json', import.meta.url), 'utf8'));

const d = v => (v ? v : null);            // '' → null (date 컬럼용)
const arr = v => (Array.isArray(v) ? v : []);

const rows = {
  options: Object.entries(src.options || {}).map(([key, values]) => ({ key, values })),
  projects: arr(src.projects).map(p => ({
    id: p.id, name: p.name ?? '', related: p.related ?? '', status: p.status ?? '',
    date: d(p.date), memo: p.memo ?? '',
  })),
  todos: arr(src.todos).map(t => ({
    id: t.id, name: t.name ?? '', tags: arr(t.tags), date: d(t.date),
    status: t.status ?? '', project_id: t.project ?? '',
  })),
  notes: arr(src.notes).map(n => ({ id: n.id, title: n.title ?? '', body: n.body ?? '' })),
  work_logs: arr(src.months).flatMap(m => arr(m.entries).map(e => ({
    id: e.id, month_key: m.key, date: d(e.date), log: e.log ?? '', memo: e.memo ?? '',
  }))),
  calendar_items: arr(src.cal).map(c => ({
    id: c.id, nid: c.nid ?? null, name: c.name ?? '', start_date: d(c.start), end_date: d(c.end),
    status: c.status ?? '', quad: c.quad ?? '', done: !!c.done, time: c.time ?? '',
    who: arr(c.who), notes: arr(c.notes),
  })),
};

console.log('이전 대상 건수:');
for (const [t, r] of Object.entries(rows)) console.log(`  ${t.padEnd(15)} ${r.length}`);
if (DRY) process.exit(0);

const { SUPABASE_ANON_KEY: KEY, SB_EMAIL: EMAIL, SB_PASSWORD: PASSWORD } = process.env;
if (!KEY || !EMAIL || !PASSWORD) {
  console.error('SUPABASE_ANON_KEY / SB_EMAIL / SB_PASSWORD 환경변수를 설정하세요.');
  process.exit(1);
}

// 로그인 → 사용자 토큰(RLS 통과용). user_id 는 DB가 auth.uid() 로 자동 채웁니다.
const auth = await fetch(`${SB_URL}/auth/v1/token?grant_type=password`, {
  method: 'POST',
  headers: { apikey: KEY, 'Content-Type': 'application/json' },
  body: JSON.stringify({ email: EMAIL, password: PASSWORD }),
});
if (!auth.ok) { console.error('로그인 실패:', await auth.text()); process.exit(1); }
const { access_token } = await auth.json();

const conflict = { options: 'user_id,key' };
for (const [table, list] of Object.entries(rows)) {
  for (let i = 0; i < list.length; i += 500) {
    const res = await fetch(`${SB_URL}/rest/v1/${table}?on_conflict=${conflict[table] || 'user_id,id'}`, {
      method: 'POST',
      headers: {
        apikey: KEY, Authorization: `Bearer ${access_token}`,
        'Content-Type': 'application/json', Prefer: 'resolution=merge-duplicates,return=minimal',
      },
      body: JSON.stringify(list.slice(i, i + 500)),
    });
    if (!res.ok) { console.error(`${table} 실패:`, await res.text()); process.exit(1); }
  }
  console.log(`✔ ${table} ${list.length}건`);
}
console.log('완료. Supabase Table Editor 에서 행 수를 위 건수와 비교해 보세요.');
