#!/usr/bin/env bash
# src/ 조각들을 합쳐 index.html 한 파일을 만듭니다.  사용: ./build.sh
set -e
cd "$(dirname "$0")"
cat src/head.html src/seed.js src/seed_helpers.js \
    src/months/cal1.js src/months/cal2.js src/months/cal3.js \
    src/months/2025-05.js src/months/2025-06.js src/months/2025-08.js src/months/2025-10.js \
    src/months/2025-12.js src/months/2026-02.js src/months/2026-04.js \
    src/tail.html > index.html
echo "built index.html ($(wc -c < index.html) bytes)"
