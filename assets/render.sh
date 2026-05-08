#!/usr/bin/env bash
# LG 문서 PDF 렌더러 — HTML 한 개를 16:9 PDF로 변환
# 사용: render.sh <input.html> <output.pdf>
# 의존성: bash + Chrome/Chromium/Edge 중 하나
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "사용법: $0 <input.html> <output.pdf>" >&2
  exit 1
fi

IN="$1"
OUT="$2"

if [[ ! -f "$IN" ]]; then
  echo "입력 HTML이 없습니다: $IN" >&2
  exit 1
fi

# 출력 디렉토리 보장
mkdir -p "$(dirname "$OUT")"

# Chrome 계열 바이너리 자동 탐색
find_chrome() {
  if [[ -n "${CHROME_BIN:-}" && -x "${CHROME_BIN}" ]]; then
    echo "$CHROME_BIN"; return 0
  fi
  local candidates=(
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    "/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary"
    "/Applications/Chromium.app/Contents/MacOS/Chromium"
    "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
    "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
  )
  for c in "${candidates[@]}"; do
    if [[ -x "$c" ]]; then echo "$c"; return 0; fi
  done
  for c in google-chrome google-chrome-stable chromium chromium-browser microsoft-edge brave-browser; do
    if command -v "$c" >/dev/null 2>&1; then echo "$(command -v "$c")"; return 0; fi
  done
  return 1
}

CHROME="$(find_chrome || true)"
if [[ -z "$CHROME" ]]; then
  cat >&2 <<'EOF'
Chrome 계열 브라우저를 찾을 수 없습니다.
다음 중 하나를 설치하거나 CHROME_BIN 환경변수로 경로를 지정해 주세요:
  - Google Chrome
  - Chromium
  - Microsoft Edge
  - Brave
EOF
  exit 1
fi

echo "[lg-doc] Chrome:  $CHROME"
echo "[lg-doc] Input:   $IN"
echo "[lg-doc] Output:  $OUT"

# 절대 경로로 변환 (file:// URL용)
ABS_IN="$(cd "$(dirname "$IN")" && pwd)/$(basename "$IN")"

# 임시 user-data-dir (다른 Chrome 세션과 충돌 방지)
TMP_USER_DIR="$(mktemp -d -t lgdoc-chrome-XXXXXX)"
trap 'rm -rf "$TMP_USER_DIR"' EXIT

"$CHROME" \
  --headless=new \
  --disable-gpu \
  --no-sandbox \
  --no-pdf-header-footer \
  --hide-scrollbars \
  --user-data-dir="$TMP_USER_DIR" \
  --virtual-time-budget=8000 \
  --print-to-pdf="$OUT" \
  "file://$ABS_IN" 2>/dev/null

if [[ ! -f "$OUT" ]]; then
  echo "PDF 생성 실패: 출력 파일이 없습니다." >&2
  exit 1
fi

SIZE=$(wc -c < "$OUT" | tr -d ' ')
if [[ "$SIZE" -lt 10000 ]]; then
  echo "PDF가 너무 작습니다 (${SIZE} bytes). 입력 HTML을 확인해 주세요." >&2
  exit 1
fi

echo "[lg-doc] 완료: $OUT (${SIZE} bytes)"
