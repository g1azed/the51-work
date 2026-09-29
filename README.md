# 🌊 더피프티원엑스 업무관리

 https://g1azed.github.io/the51-work/

노션의 "더피프티원엑스 업무관리" 페이지를 단일 HTML 앱으로 옮긴 프로젝트입니다.
`index.html` 하나로 동작하며, 데이터는 **Supabase**(Postgres)에 저장됩니다.

## 사용 방법

1. `index.html`(또는 위 주소)을 브라우저로 엽니다.
2. 상단 **로그인 필요** 버튼 → Supabase에 만든 계정(이메일/비밀번호)으로 로그인합니다.
3. 이후 할 일·일정·일지를 수정하면 1초 뒤 바뀐 항목만 자동 저장되고,
   다른 기기에서 수정한 내용은 탭으로 돌아올 때 자동으로 불러옵니다.

데이터 확인·수정·CSV 내보내기는 Supabase 대시보드 → **Table Editor** 에서 할 수 있습니다.
로그인하지 않으면 이 브라우저(localStorage)에만 저장됩니다.

## 구성

| 화면 | 내용 |
|---|---|
| 대시보드 | To do List(체크리스트) · Projects(카드, 완료율) · Note(메모) |
| 캘린더 & 리스트 | 마감일 기준 월간 캘린더 + 4분면 시간 관리법 보드(작업중/대기/반영대기/추후작업, 드래그앤드롭) + 작업시간 정리표(MD 환산) |
| 업무일지 | 월별 업무일지 (2025.05 ~), 셀 클릭 즉시 편집, 검색 |

## 개발

```
src/
  head.html        # 마크업 + CSS
  tail.html        # 앱 로직 (렌더, 다이얼로그, Supabase 동기화)
  seed.js          # 옵션 기본값(상태/태그/기획자 등)과 빈 초기 상태 — 실제 데이터는 Supabase
supabase/
  schema.sql       # 테이블 + RLS 정의 (SQL Editor 에서 실행, 여러 번 실행해도 안전)
  migrate.mjs      # 예전 data.json → Supabase 1회성 이전 스크립트 (이전 완료, 기록용)
build.sh           # src/ → index.html 조립
```

수정 후 `./build.sh` 로 `index.html`을 다시 만듭니다.
Supabase URL과 anon 키(공개용)는 `src/tail.html` 의 `SB_URL`, `SB_ANON_KEY` 에 있고, 접근은 RLS(본인 행만)로 제한됩니다.
예전 `data/data.json` 은 git 기록(커밋 `f0032a9`)에 남아 있습니다: `git show f0032a9:data/data.json`
