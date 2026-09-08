# 🌊 더피프티원엑스 업무관리


 https://g1azed.github.io/the51-work/

노션의 "더피프티원엑스 업무관리" 페이지를 단일 HTML 앱으로 옮긴 프로젝트입니다.
서버 없이 `index.html` 하나로 동작하며, 데이터는 이 저장소의 `data/data.json`에 자동 저장됩니다.

## 사용 방법

1. 저장소를 클론하거나 `index.html`을 내려받아 브라우저로 엽니다.
2. 상단 **동기화** 버튼 → GitHub Personal Access Token(아래 참고)을 입력하고 저장합니다.
3. 이후 할 일·일정·일지를 수정하면 1.5초 뒤 `data/data.json`이 자동 커밋되고,
   앱을 열 때마다 저장소의 최신 데이터를 불러옵니다. 어느 컴퓨터/브라우저에서 열어도 같은 데이터를 봅니다.

### 토큰 만들기 (Fine-grained PAT)

GitHub → Settings → Developer settings → Personal access tokens → **Fine-grained tokens** → Generate new token

- Repository access: **Only select repositories → the51x-work**
- Permissions → Repository permissions → **Contents: Read and write**

토큰은 브라우저 localStorage에만 저장되며, GitHub API 호출 외에는 사용되지 않습니다.

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
  tail.html        # 앱 로직 (렌더, 다이얼로그, GitHub 동기화)
  seed.js          # 초기 데이터 (프로젝트/할 일/메모/2026.07~09 일지)
  seed_helpers.js  # 시드 헬퍼
  months/          # 과거 업무일지 · 캘린더 일정 시드
data/data.json     # 실제 데이터 (앱이 자동 커밋)
build.sh           # src/ → index.html 조립
```

수정 후 `./build.sh` 로 `index.html`을 다시 만듭니다.
`data/data.json`이 있는 한 시드는 최초 1회(또는 초기화 버튼)에만 사용됩니다.
