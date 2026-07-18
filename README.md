# Design Gallery — 프론트엔드 디자인 레퍼런스 플랫폼

유명 웹·앱 디자인을 **의존성 없는 동작 코드**로 재현하고, AI로 만든 이미지·영상과 실시간 3D까지 담은 레퍼런스 갤러리.
보기만 하는 스크린샷이 아니라, 열어서 만져보고 복사해서 바로 쓰는 것이 목표입니다.

🔗 **Live:** https://hyunaeee.github.io/design-gallery/

---

## 무엇인가요

각 데모는 **하나의 HTML 파일**로 완결됩니다 — 인라인 CSS/JS, 빌드 도구 없음, 외부 의존성 최소화(Google Fonts `@import`, 일부 데모의 three.js CDN 정도). 갤러리(`index.html`)에서 카드를 열면 라이브 미리보기와 소스를 함께 볼 수 있습니다.

- **69개 데모** — 어워드급 웹·랜딩·에디토리얼·포트폴리오·인터랙티브 실험 + 모바일 앱 UI
- **KO / EN** — 데모 내부 텍스트까지 전부 이중언어 (`?lang=en`, 갤러리 토글로 자동 전파)
- **AI 생성 에셋** — 이미지·영상은 Higgsfield로 생성 후 배경 제거(누끼)·경량화 (`assets/gen/`)
- **WebGL / Three.js** — 실시간 3D를 활용한 데모 포함
- **PDF 출력** — 개발자 포트폴리오는 `@media print`로 깔끔하게 인쇄/PDF 저장

## 눈에 띄는 데모

| 데모 | 설명 |
|---|---|
| **Y2K CLOSET** (`demos/dressup-crew.html`) | 한 실루엣에서 파생한 5인 패션돌 자유 배치 옷입히기 — 끌어서 입히고, 휠로 크기 조절, 21개 AI 아이템·일러스트 배경 5종 |
| **COSMOS** (`demos/cosmos-life.html`) | 크레센도 모양 3D 압출 글자 안에서 AI 해파리 영상이 느리게 재생, 원근으로 멀어지며 물결 — 스크롤하면 별빛 입자 500→14,000개 |
| **BLUESCREEN.SYS** (`demos/ascii-bluescreen.html`) | 이미지 0장, 전부 글자로 지은 블루스크린 홈페이지 — BSOD 부팅, 숫자키 내비, 걸어다니는 ASCII 행인 |
| **INTERFACE PARK** (`demos/ride-map.html`) | AI 지도 위, 배경 제거한 놀이기구를 호버하면 실루엣이 빛나고 클릭하면 입장 |
| **STUDIO HOURS** (`demos/creator-room.html`) | 같은 작업실의 낮/노을/밤 전환 · 불 켜기 · 방 안 오브젝트 클릭 · 3D 캐릭터 반응 |
| **PERLE** (`demos/folio-pearl.html`) | AI 진주빛 실크 영상이 배경에서 이음매 없이 재생되고 스크롤로 속도가 변하는 럭셔리 포트폴리오 |
| **FALL** (`demos/scroll-story.html`) | three.js(WebGL) + 언리얼 블룸으로 네온 링 터널을 통과해 낙하하는 3D 다이브 |
| **개발자 포트폴리오 3종** (`demos/dev-*.html`) | 터미널형 · A4 이력서형 · 카드형 — 전부 "PDF로 저장" 지원 |
| **NEON DIVE** (`demos/cyberpunk-landing.html`) | 요원 선택·무기고·패치노트·예고편을 오가는 멀티페이지 게임 런처 |

이 외에도 Stripe·Vercel·Linear·Apple·Airbnb·싸이월드 스타일 재현, 파티클/캔버스 실험, Wix 템플릿형 사이트, 미니멀 흑백 포트폴리오, 폰 프레임 앱 UI 등이 있습니다.

## 실행

정적 파일 서버면 무엇이든 됩니다 (코드 뷰어의 fetch·상대경로 에셋 때문에 `file://` 직접 열기는 권장하지 않음).

```bash
python -m http.server 5533       # 또는  npx serve .
# → http://localhost:5533
```

개별 데모는 `http://localhost:5533/demos/<파일>.html`, 영어 모드는 `?lang=en`.

## 구성

```
index.html            갤러리 플랫폼 (검색·태그/용도 필터·웹/앱 탭·즐겨찾기·코드 뷰어 모달·KO/EN)
demos/                데모 본체 — 전부 자립형 단일 HTML (69개)
  ├─ 💻 웹: 어워드급(비디오 히어로·WebGL·three.js·브루탈리즘·3D 씬) + 클래식 재현 + 포트폴리오/템플릿
  └─ 📱 앱: 폰 프레임 UI (뮤직·러닝·식물케어·채팅·커머스 등)
assets/gen/           AI(Higgsfield) 생성 이미지·영상 (경량화됨)
exports/              일부 앱 데모의 멀티 플랫폼 익스포트
  ├─ tokens/          디자인 토큰 JSON (Tokens Studio → 피그마)
  ├─ react-native/    RN 컴포넌트 (Expo Snack 즉시 실행)
  ├─ flutter/         Flutter 위젯 (DartPad 즉시 실행)
  └─ swiftui/         SwiftUI 뷰 (Xcode #Preview)
LICENSE               MIT + 서드파티 고지
```

## 플랫폼 사용법

| 기능 | 방법 |
|---|---|
| 검색 | `/` 키 → 키워드 입력 |
| 웹/앱 전환 | 상단 ✦/💻/📱 탭 |
| 언어 | 우상단 KO/EN 토글 (데모 내부까지 전파) |
| 즐겨찾기 | 카드의 ♡ → 툴바 "♥"로 모아보기 (localStorage) |
| 데모 탐색 | 모달에서 `←` `→` 또는 ‹ › 버튼 |
| 코드 복사 | 모달 각 탭 → "📋 전체 코드 복사" |

## 디자인 → 코드 워크플로우

- **피그마**: 모달 🎨 토큰 탭 복사 → Tokens Studio 플러그인 Load from JSON → 변수/스타일 생성
- **RN**: snack.expo.dev 붙여넣기 (외부 패키지 0) · **Flutter**: dartpad.dev · **SwiftUI**: Xcode 새 파일 → `#Preview`

## 데모 추가 컨벤션

- 자립형 단일 HTML, 한국어 기본 + `?lang=en`, Google Fonts `@import`만 허용(에셋은 `assets/gen/` 상대경로)
- 무한 rAF 루프는 `window.__paused` 가드 필수:
  `if (window.__paused && frames > 5) { setTimeout(() => requestAnimationFrame(loop), 300); return; }`
- 루프가 읽는 변수는 루프보다 먼저 선언(TDZ 방지), 엔트런스는 IntersectionObserver 사용
- 파일 상단에 MIT 헤더 주석 유지

## 라이선스

MIT © 2026 hyunaeee — 전문은 [LICENSE](LICENSE).

이 프로젝트는 **디자인 레퍼런스/학습용** 갤러리입니다. 일부 데모는 잘 알려진 제품(Stripe, Vercel, Linear, Apple, Airbnb, 싸이월드 등)의 디자인을 교육 목적으로 재현하며 **모든 제품명·로고·브랜드는 각 소유자의 상표**입니다. MIT 라이선스는 이 저장소의 원본 코드에만 적용됩니다. `demos/card-tilt-3d.html`은 simey의 `pokemon-cards-css` 기법을 재현하며 파일 내 출처 표기를 유지합니다. `assets/gen/`의 이미지·영상은 AI(Higgsfield)로 생성되었습니다.
