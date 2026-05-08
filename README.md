# claude-skill-lg-doc

텍스트나 마크다운을 붙여 넣고 **"LG 문서로 만들자"** 한 마디면, LG 공정보고 PPT 톤(LG스마트체2.0, 회색 미니멀, 16:9 슬라이드)으로 PDF가 떨어지는 [Claude Code](https://claude.ai/claude-code) 스킬입니다.

표지 → 목차 → 본문 → 마무리 슬라이드를 자동으로 구성해 주고, 마크다운 표도 LG 톤으로 스타일링합니다.

---

## 가장 빠른 설치: Claude Code에 그대로 시키기

새 PC의 Claude Code 세션에 아래 한 줄을 그대로 붙여 넣으세요. 클로드가 알아서 다운로드하고 환경 점검까지 해 줍니다.

```
https://github.com/teamjcurve-ai/claude-skill-lg-doc 이 스킬을 install.sh 스크립트로 설치해 줘.
```

또는 터미널에서 직접 한 줄로 설치:

```bash
curl -sSL https://raw.githubusercontent.com/teamjcurve-ai/claude-skill-lg-doc/main/install.sh | bash
```

설치가 끝나면 Claude Code 세션에서 마크다운/텍스트 첨부 후 **"LG 문서로 만들자"** 라고 입력하면 됩니다.

---

## 미리 보기

`examples/sample.pdf` 참고. 8페이지 데모(표지·목차·본문 5장·마무리, 표 1개).

## 요구사항

1. **Claude Code** 설치
2. **Chrome / Chromium / Edge / Brave 중 하나** (PDF 변환 엔진 — 거의 모든 PC에 이미 있음)
3. **LG스마트체2.0 폰트** 본인 PC에 시스템 설치 (선택이지만 강력 추천)
   - 미설치 시 시스템 기본 한글 폰트로 폴백되어 LG 톤이 살지 않습니다.
   - 설치 파일은 LG 공식 채널에서 받아 시스템 폰트로 등록.

## 수동 설치

자동 스크립트가 부담스러우면 수동으로:

```bash
git clone https://github.com/teamjcurve-ai/claude-skill-lg-doc.git \
  ~/.claude/skills/lg-doc
```

이게 끝입니다. Claude Code가 자동으로 `~/.claude/skills/` 아래 스킬을 인식합니다.

## 사용

Claude Code 세션에서 마크다운(또는 일반 텍스트)을 첨부하고 다음 중 하나를 입력:

- "LG 문서로 만들자"
- "LG 슬라이드 PDF로 뽑아줘"
- "이 텍스트 LG 템플릿으로 변환"
- "공정보고 LG로"

생성된 PDF는 `~/Documents/lg-docs/<제목>-<날짜>.pdf`에 저장됩니다.

### 입력 예시

```markdown
---
title: 2026년 1분기 사업 계획
subtitle: 신사업 추진 현황 보고
author: 홍길동
date: 2026-05-08
---

# 2026년 1분기 사업 계획

## 추진 배경
시장 환경 변화에 따라 ...

## 핵심 과제
- 제품 라인업 재편
- 신규 채널 발굴

## 투자 계획
| 항목 | 1분기 | 2분기 | 비고 |
|---|---|---|---|
| R&D | 30억 | 35억 | 신소재 |
| 마케팅 | 12억 | 18억 | 디지털 강화 |

## 기대 효과
...
```

frontmatter 블록은 선택. 없으면 첫 H1이 제목이 되고 부제·작성자·작성일은 한 번만 묶어 묻습니다.

## 결과물 구성

- **표지** — 제목 + 부제 + 좌하단 작성일·작성자 + 우하단 © 2026 LG
- **목차** — 본문 H2 항목들을 번호 매겨 나열
- **본문** — H2당 슬라이드 1장 이상, 분량 넘치면 자동 분할
- **마무리** — "감사합니다"
- **푸터** — `CONFIDENTIAL | n / total`

## 트러블슈팅

| 증상 | 원인·해결 |
|---|---|
| 글꼴이 LG 톤이 아님 | LG스마트체2.0이 시스템 폰트로 설치돼 있는지 확인 |
| `Chrome 계열 브라우저를 찾을 수 없습니다` | Chrome 또는 Edge 설치, 또는 `export CHROME_BIN=/path/to/chrome` |
| PDF가 비어있음 | `/tmp/lg-doc-*.html`을 브라우저로 직접 열어 비교 |
| 슬라이드 본문이 잘림 | 한 H2 안의 분량을 줄이거나, 클로드에게 "더 잘게 나눠"라고 지시 |

## 라이선스

MIT. 단, **LG 폰트는 본 repo에 포함되어 있지 않으며** LG의 별도 라이선스를 따릅니다. 사용자가 본인 책임으로 폰트를 설치해 사용하세요.

## 만든 사람

[Team J-Curve](https://teamjcurve.com) — LG 강의 운영팀
