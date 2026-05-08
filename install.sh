#!/usr/bin/env bash
# claude-skill-lg-doc 설치 스크립트
# 사용:
#   curl -sSL https://raw.githubusercontent.com/teamjcurve-ai/claude-skill-lg-doc/main/install.sh | bash
# 또는 이미 clone 받았다면:
#   bash ~/.claude/skills/lg-doc/install.sh
set -euo pipefail

REPO_URL="https://github.com/teamjcurve-ai/claude-skill-lg-doc.git"
TARGET_DIR="${HOME}/.claude/skills/lg-doc"

c_red() { printf "\033[31m%s\033[0m" "$*"; }
c_grn() { printf "\033[32m%s\033[0m" "$*"; }
c_yel() { printf "\033[33m%s\033[0m" "$*"; }
c_dim() { printf "\033[2m%s\033[0m" "$*"; }

echo
echo "  $(c_grn '●') claude-skill-lg-doc 설치를 시작합니다."
echo

# 1) git clone (이미 있으면 pull)
if [[ -d "$TARGET_DIR/.git" ]]; then
  echo "  $(c_dim '·') 이미 설치돼 있어 최신 버전으로 갱신합니다: $TARGET_DIR"
  git -C "$TARGET_DIR" pull --ff-only
elif [[ -d "$TARGET_DIR" ]]; then
  echo "  $(c_red '✖') $TARGET_DIR 가 이미 존재하지만 git repo가 아닙니다."
  echo "    이 디렉토리를 다른 곳으로 옮긴 뒤 다시 실행해 주세요."
  exit 1
else
  mkdir -p "$(dirname "$TARGET_DIR")"
  echo "  $(c_dim '·') 다운로드: $REPO_URL"
  git clone --depth 1 "$REPO_URL" "$TARGET_DIR"
fi

chmod +x "$TARGET_DIR/assets/render.sh" 2>/dev/null || true

echo
echo "  $(c_grn '●') 환경 점검"

# 2) Chrome 계열 브라우저 탐색
find_chrome() {
  if [[ -n "${CHROME_BIN:-}" && -x "${CHROME_BIN}" ]]; then echo "$CHROME_BIN"; return; fi
  for c in \
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    "/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary" \
    "/Applications/Chromium.app/Contents/MacOS/Chromium" \
    "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" \
    "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"; do
    [[ -x "$c" ]] && echo "$c" && return
  done
  for c in google-chrome google-chrome-stable chromium chromium-browser microsoft-edge brave-browser; do
    command -v "$c" >/dev/null 2>&1 && command -v "$c" && return
  done
}

CHROME="$(find_chrome || true)"
if [[ -n "$CHROME" ]]; then
  echo "  $(c_grn '✓') Chrome 계열 브라우저 발견: $(c_dim "$CHROME")"
else
  echo "  $(c_yel '!') Chrome 계열 브라우저를 찾지 못했습니다."
  echo "    Google Chrome, Chromium, Microsoft Edge, Brave 중 하나를 설치하거나"
  echo "    CHROME_BIN 환경변수에 경로를 지정해 주세요."
fi

# 3) LG 폰트 점검 (macOS 기준 ~/Library/Fonts, 시스템 ~/Library/Fonts/, /Library/Fonts/)
font_count=0
for d in "$HOME/Library/Fonts" "/Library/Fonts" "$HOME/.fonts" "/usr/share/fonts" "/usr/local/share/fonts"; do
  [[ -d "$d" ]] || continue
  n=$(find "$d" -maxdepth 3 -type f \( -iname 'LGSMHA*.ttf' -o -iname '*LGSmart*' -o -iname '*LG스마트체*' \) 2>/dev/null | wc -l | tr -d ' ')
  font_count=$((font_count + n))
done

if [[ "$font_count" -gt 0 ]]; then
  echo "  $(c_grn '✓') LG스마트체2.0 폰트 ${font_count}개 감지"
else
  echo "  $(c_yel '!') LG스마트체2.0 폰트가 시스템에 설치돼 있지 않습니다."
  echo "    LG 톤이 안 살고 시스템 기본 한글 폰트로 폴백됩니다."
  echo "    LG 공식 채널에서 폰트(.ttf 8종)를 받아 시스템 폰트로 등록해 주세요."
fi

echo
echo "  $(c_grn '●') 설치 완료"
echo
echo "  사용 방법:"
echo "    1. Claude Code 세션에서 마크다운 또는 텍스트를 첨부"
echo "    2. \"$(c_grn 'LG 문서로 만들자')\" 라고만 입력"
echo "    3. 결과는 ~/Documents/lg-docs/ 아래 PDF로 저장됩니다."
echo
echo "  더 자세히는: $TARGET_DIR/README.md"
echo
