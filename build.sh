#!/usr/bin/env bash
# src/ 조각들을 합쳐 index.html 한 파일을 만듭니다.  사용: ./build.sh
set -e
cd "$(dirname "$0")"
cat src/head.html src/seed.js src/tail.html > index.html
echo "built index.html ($(wc -c < index.html) bytes)"
