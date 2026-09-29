-- Created: 2026-09-29 14:03:00
-- the51-work Supabase 스키마. Supabase 대시보드 > SQL Editor 에 통째로 붙여넣고 Run 하세요.
-- 모든 테이블은 RLS(행 수준 보안)로 "로그인한 본인 데이터만" 읽고 쓰게 됩니다.

-- ── 옵션(상태/태그/연관/기획자 목록) ─────────────────────────────
create table if not exists options (
  user_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  key        text not null,              -- related | status | tags | calStatus | quad | who
  "values"   jsonb not null default '[]',
  updated_at timestamptz not null default now(),
  primary key (user_id, key)
);

-- ── 프로젝트 ────────────────────────────────────────────────────
create table if not exists projects (
  user_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  id         text not null,              -- 앱에서 쓰는 id (p1, p2 ...)
  name       text not null default '',
  related    text not null default '',
  status     text not null default '',
  date       date,
  memo       text not null default '',
  updated_at timestamptz not null default now(),
  primary key (user_id, id)
);

-- ── 할 일 ───────────────────────────────────────────────────────
create table if not exists todos (
  user_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  id         text not null,
  name       text not null default '',
  tags       text[] not null default '{}',
  date       date,
  status     text not null default '',
  project_id text not null default '',   -- projects.id (빈 값 = 프로젝트 없음)
  updated_at timestamptz not null default now(),
  primary key (user_id, id)
);

-- ── 메모 ────────────────────────────────────────────────────────
create table if not exists notes (
  user_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  id         text not null,
  title      text not null default '',
  body       text not null default '',
  updated_at timestamptz not null default now(),
  primary key (user_id, id)
);

-- ── 업무일지 (월별 묶음은 month_key 로 표현) ─────────────────────
create table if not exists work_logs (
  user_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  id         text not null,
  month_key  text not null,              -- 예: 2026-09
  date       date,
  log        text not null default '',
  memo       text not null default '',
  updated_at timestamptz not null default now(),
  primary key (user_id, id)
);
create index if not exists work_logs_month_idx on work_logs (user_id, month_key, date);

-- ── 캘린더 일정 / 4분면 보드 ────────────────────────────────────
create table if not exists calendar_items (
  user_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  id         text not null,
  nid        integer,
  name       text not null default '',
  start_date date,
  end_date   date,
  status     text not null default '',
  quad       text not null default '',
  done       boolean not null default false,
  time       text not null default '',
  who        text[] not null default '{}',
  notes      jsonb not null default '[]',
  updated_at timestamptz not null default now(),
  primary key (user_id, id)
);
create index if not exists calendar_items_start_idx on calendar_items (user_id, start_date);

-- ── updated_at 자동 갱신 ────────────────────────────────────────
create or replace function set_updated_at() returns trigger
language plpgsql as $$
begin new.updated_at = now(); return new; end $$;

do $$
declare t text;
begin
  foreach t in array array['options','projects','todos','notes','work_logs','calendar_items'] loop
    execute format('drop trigger if exists trg_%1$s_updated on %1$s', t);
    execute format('create trigger trg_%1$s_updated before update on %1$s
                    for each row execute function set_updated_at()', t);
  end loop;
end $$;

-- ── RLS: 본인 행만 접근 ─────────────────────────────────────────
do $$
declare t text;
begin
  foreach t in array array['options','projects','todos','notes','work_logs','calendar_items'] loop
    execute format('alter table %I enable row level security', t);
    execute format('drop policy if exists "own rows" on %I', t);
    execute format('create policy "own rows" on %I for all
                    using (user_id = auth.uid()) with check (user_id = auth.uid())', t);
  end loop;
end $$;

-- ── 2026-09-29 14:40 추가: 앱에서 쓰는 필드(기획자/RMS/작업시간) 컬럼 ─────
-- 이미 위 내용을 실행했어도 이 파일 전체를 다시 Run 해도 안전합니다(전부 "if not exists").
alter table todos          add column if not exists designer text not null default '';
alter table todos          add column if not exists rms      text not null default '';
alter table calendar_items add column if not exists hours    integer;
alter table calendar_items add column if not exists designer text not null default '';
alter table calendar_items add column if not exists rms      text not null default '';
notify pgrst, 'reload schema';
