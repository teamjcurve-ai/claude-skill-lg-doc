---
name: lg-doc
description: 첨부된 텍스트/마크다운(표 포함)을 LG 공정보고 PPT 톤(LG스마트체2.0, 회색 미니멀, 16:9 슬라이드)으로 변환해 PDF로 떨어뜨리는 스킬. "LG 문서로 만들자", "LG 슬라이드로", "LG 템플릿 PDF", "공정보고 LG로", "이 텍스트 LG 문서로", "LG 문서 PDF" 같은 요청에 호출. 결과는 ~/Documents/lg-docs/ 아래 PDF 파일.
---

# lg-doc — LG 문서 PDF 변환 스킬

사용자가 텍스트 또는 마크다운을 붙여 "LG 문서로 만들자"라고 하면 16:9 슬라이드 PDF로 변환한다. LG 폰트는 사용자 PC에 설치된 것을 시스템 참조로 사용한다(repo에 폰트 파일 미포함).

## 호출 시 즉시 수행

### 1. 입력 정제
- 사용자 첨부가 일반 텍스트면 마크다운으로 한 번 정돈 (단락 구분, 자연스러운 헤딩 부여, 표가 보이면 마크다운 테이블로).
- 마크다운이면 그대로 사용.
- 표 5컬럼 또는 15행 초과면 본문 슬라이드 HTML에서 `<table class="compact">`로 렌더.

### 2. 메타 추출 (한 번에 묶어 묻기)
필요 메타: 제목, 부제, 작성자, 작성일.
- 입력 frontmatter(YAML) 또는 첫 H1에서 추출 시도.
- 없는 항목만 "한 메시지에서 한 번에" 사용자에게 묻기. 3개 이하면 묻지 말고 합리적 기본값(작성일=오늘, 부제=빈값, 작성자="작성자")으로 진행.

### 3. 슬라이드 분할 규칙
1. **표지 슬라이드** (1장) — H1 = 제목, 부제·작성자·작성일 표시
2. **목차 슬라이드** (1장) — 본문 H2 항목들을 번호 매겨 나열
3. **본문 슬라이드** (H2당 1장 이상) — H3는 슬라이드 내 서브헤딩
4. **마무리 슬라이드** (1장) — "감사합니다"

본문 슬라이드 한 장의 분량 제한:
- 텍스트 14줄 또는 600자 초과 시 같은 H2를 둘 이상으로 분할 ("Section Title (cont.)")
- 표가 들어간 슬라이드는 표 외 본문 6줄 이내로 제한

### 4. HTML 합성

`assets/template.html`을 베이스로 한다. **CSS는 그대로 유지**하고 `<body>` 안의 슬라이드만 입력에 맞춰 새로 합성한다.

각 슬라이드 HTML 패턴 (template.html 안의 예시 그대로):

**표지**
```html
<section class="slide cover">
  <h1>{TITLE}</h1>
  <p class="subtitle">{SUBTITLE}</p>
  <div class="cover-foot">
    <span class="meta">{YYYY.MM.DD} · {AUTHOR}</span>
    <span class="copy">© 2026 LG</span>
  </div>
</section>
```

**목차** (`{N}` = 총 페이지 수)
```html
<section class="slide toc">
  <header class="slide-head">
    <h2 class="slide-title">목차</h2>
    <span class="section-num">CONTENTS</span>
  </header>
  <ol class="toc-list">
    <li><span class="num">01</span><span class="text">{H2 제목 1}</span></li>
    <li><span class="num">02</span><span class="text">{H2 제목 2}</span></li>
  </ol>
  <footer class="page-footer">CONFIDENTIAL  |  2 / {N}</footer>
</section>
```

**본문**
```html
<section class="slide body">
  <header class="slide-head">
    <h2 class="slide-title">{H2 제목}</h2>
    <span class="section-num">SECTION 0{i}</span>
  </header>
  <div class="slide-body">
    {본문 마크다운을 HTML로 변환한 결과}
  </div>
  <footer class="page-footer">CONFIDENTIAL  |  {p} / {N}</footer>
</section>
```

**마무리**
```html
<section class="slide outro">
  <h1>감사합니다</h1>
  <div class="outro-foot">© 2026 LG</div>
</section>
```

마크다운 → HTML 변환 시 사용 가능한 태그: `<h3>`, `<p>`, `<ul>/<ol>/<li>`, `<strong>`, `<em>`, `<code>`, `<blockquote>`, `<table>/<thead>/<tbody>/<tr>/<th>/<td>`. CSS가 자동으로 LG 톤으로 스타일링한다.

### 5. 파일 출력 + PDF 변환

1. 합성한 HTML을 `/tmp/lg-doc-<timestamp>.html`에 Write.
2. PDF 출력 경로: `~/Documents/lg-docs/<slug>-<YYYYMMDD>.pdf`
   - slug = 제목 한글 그대로 + 공백 → `-` 치환 + 특수문자 제거
3. `mkdir -p ~/Documents/lg-docs` 후
4. `bash ~/.claude/skills/lg-doc/assets/render.sh <html> <pdf>` 실행
5. 결과 파일 크기 확인 (>10KB)

### 6. 보고
사용자에게 다음만 짧게:
```
PDF 생성 완료: <경로>
슬라이드 N장, 표 M개
```
질문이 없으면 추가 설명 금지.

## 가드레일

- LG 폰트 파일을 HTML에 base64로 임베드하지 말 것 (라이선스). CSS `font-family` 시스템 참조만 사용.
- 외부 CDN, 외부 이미지, JS 라이브러리 금지. 모든 자산 인라인.
- 슬라이드당 14줄 / 600자 초과 시 자동 분할.
- 표 5컬럼·15행 초과 시 `class="compact"` 적용.
- 본문 폭은 max-width 1120px 유지 (CSS에 이미 설정).
- 푸터 페이지 번호는 표지·마무리 제외하고 모든 슬라이드에 표시.

## 트러블슈팅 (사용자가 결과물 이상 신고할 때)

- **글꼴이 LG 톤이 아님** → 사용자 PC에 LG스마트체2.0 8종이 설치돼 있는지 확인 안내. 미설치면 LG 공식 폰트 페이지에서 다운받아 시스템 폰트로 설치 권유.
- **Chrome을 못 찾음** → README의 요구사항 섹션 안내. `CHROME_BIN` env로 경로 지정 가능.
- **PDF가 비어있거나 깨짐** → `/tmp/lg-doc-*.html`을 사용자가 브라우저로 직접 열어 보고 결과 비교.
