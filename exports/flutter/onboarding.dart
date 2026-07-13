// Copyright (c) 2026 hyunaeee · MIT License — see /LICENSE at the project root.
// ─────────────────────────────────────────────────────────────
// onboarding.dart — 온보딩 → 로그인 플로우 (Flutter)
// 용도: 3장 캐러셀 온보딩(PageView + dots) → 마지막 장/건너뛰기에서
//       소셜 로그인 화면 전환 ('마지막 로그인' 뱃지 포함)
// 실행: https://dartpad.dev 새 Flutter 스니펫에 파일 전체를 붙여넣고 Run
//       (flutter/material.dart 만 사용 — 외부 패키지 없음)
// 토큰: exports/tokens/onboarding.tokens.json 과 1:1 대응 (class T)
// ─────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

void main() => runApp(const OnboardingApp());

/* ── 디자인 토큰 (onboarding.tokens.json) ── */
class T {
  static const primary = Color(0xFF6C5CE7); //   color.primary — 브랜드 바이올렛
  static const bg = Color(0xFFFFFFFF); //        color.background
  static const ink = Color(0xFF1D1B2E); //       color.text-primary
  static const sub = Color(0xFF8C88A3); //       color.text-secondary
  static const dotOff = Color(0xFFE3E0F0); //    color.dot-inactive
  static const kakao = Color(0xFFFEE500); //     color.kakao
  static const naver = Color(0xFF03C75A); //     color.naver
  static const apple = Color(0xFF111111); //     color.apple
  static const email = Color(0xFFF2F2F7); //     color.email
  static const lastLogin = Color(0xFFFF4757); // color.last-login — 뱃지
  static const double radiusCta = 16; //         radius.cta
  static const double radiusSocial = 14; //      radius.social
  static const double radiusArt = 64; //         radius.art
  static const double artSize = 220; //          component.art-size
}

class Slide {
  const Slide(this.emoji, this.bg, this.title, this.body);
  final String emoji;
  final List<Color> bg;
  final String title, body;
}

const kSlides = [
  Slide('🗂️', [Color(0xFFECE9FB), Color(0xFFDCD6F7)],
      '흩어진 디자인 레퍼런스,\n한 곳에 모아요',
      '웹과 앱, 패턴과 컴포넌트별로 정리된\n레퍼런스를 검색 한 번으로 찾으세요.'),
  Slide('⚡', [Color(0xFFE0F7F5), Color(0xFFC5EDE9)],
      '보기만 하지 말고\n바로 코드로 쓰세요',
      '모든 레퍼런스는 동작하는 코드와 함께.\n복사해서 프로젝트에 붙여넣으면 끝.'),
  Slide('🤝', [Color(0xFFFFF2E0), Color(0xFFFFE3C2)],
      '팀과 함께 쓰면\n더 강력해져요',
      '컬렉션을 만들어 공유하고\n우리 팀의 디자인 언어를 만들어 가세요.'),
];

class Social {
  const Social(this.label, this.bg, this.fg, [this.last = false]);
  final String label;
  final Color bg, fg;
  final bool last;
}

const kSocials = [
  Social('💬 카카오로 계속하기', T.kakao, Color(0xFF191600), true),
  Social('N 네이버로 계속하기', T.naver, Colors.white),
  Social(' Apple로 계속하기', T.apple, Colors.white),
  Social('✉️ 이메일로 계속하기', T.email, T.ink),
];

class OnboardingApp extends StatelessWidget {
  const OnboardingApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: T.bg),
        home: const OnboardingFlow(),
      );
}

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _pageCtrl = PageController();
  int _idx = 0;
  bool _showLogin = false;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  /* '다음' — 마지막 장이면 로그인 화면 전환 */
  void _next() {
    if (_idx < kSlides.length - 1) {
      _pageCtrl.animateToPage(_idx + 1,
          duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
    } else {
      setState(() => _showLogin = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // 온보딩 ↔ 로그인 화면 전환 (원본 .gone/.waiting 슬라이드+페이드)
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(.12, 0), end: Offset.zero).animate(anim),
              child: child,
            ),
          ),
          child: _showLogin ? _loginView() : _onboardingView(),
        ),
      ),
    );
  }

  // ── 온보딩 캐러셀 뷰 ──
  Widget _onboardingView() => Stack(
        key: const ValueKey('ob'),
        children: [
          Column(children: [
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: kSlides.length,
                onPageChanged: (i) => setState(() => _idx = i),
                itemBuilder: (_, i) => _slide(kSlides[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 12, 26, 42),
              child: Column(children: [
                // 페이지 dots — 활성 dot 은 22px 캡슐로 확장
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  for (var i = 0; i < kSlides.length; i++) ...[
                    if (i > 0) const SizedBox(width: 7),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _idx == i ? 22 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: _idx == i ? T.primary : T.dotOff,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ],
                ]),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _next,
                    style: FilledButton.styleFrom(
                      backgroundColor: T.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(T.radiusCta)),
                    ),
                    child: Text(_idx == kSlides.length - 1 ? '시작하기' : '다음',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ),
          ]),
          Positioned(
            top: 12, right: 22,
            child: TextButton(
              onPressed: () => setState(() => _showLogin = true),
              child: const Text('건너뛰기', style: TextStyle(fontSize: 13.5, color: T.sub)),
            ),
          ),
        ],
      );

  Widget _slide(Slide sl) => Padding(
        padding: const EdgeInsets.fromLTRB(34, 60, 34, 20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: T.artSize, height: T.artSize, alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight, colors: sl.bg),
              borderRadius: BorderRadius.circular(T.radiusArt),
            ),
            child: Text(sl.emoji, style: const TextStyle(fontSize: 88)),
          ),
          const SizedBox(height: 44),
          Text(sl.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 25, fontWeight: FontWeight.w900, height: 1.35,
                  letterSpacing: -.5, color: T.ink)),
          const SizedBox(height: 13),
          Text(sl.body,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14.5, height: 1.75, color: T.sub)),
        ]),
      );

  // ── 로그인 뷰 (소셜 버튼 + '마지막 로그인' 뱃지) ──
  Widget _loginView() => Stack(
        key: const ValueKey('login'),
        children: [
          Column(children: [
            const SizedBox(height: 96),
            Container(
              width: 76, height: 76, alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)]),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                      color: T.primary.withOpacity(.55), blurRadius: 34,
                      offset: const Offset(0, 16), spreadRadius: -10),
                ],
              ),
              child: const Text('◈', style: TextStyle(fontSize: 38, color: Colors.white)),
            ),
            const SizedBox(height: 24),
            const Text('디자인 갤러리 시작하기',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -.5, color: T.ink)),
            const SizedBox(height: 8),
            const Text('3초 만에 가입하고 모든 레퍼런스를 저장하세요',
                style: TextStyle(fontSize: 13.5, color: T.sub)),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(children: [
                for (var i = 0; i < kSocials.length; i++) ...[
                  if (i > 0) const SizedBox(height: 11),
                  _socialBtn(kSocials[i]),
                ],
              ]),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 44),
              child: Text.rich(
                TextSpan(
                  text: '이미 계정이 있나요? ',
                  style: const TextStyle(fontSize: 12.5, color: T.sub),
                  children: [
                    TextSpan(
                        text: '로그인',
                        style: const TextStyle(color: T.primary, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ]),
          Positioned(
            top: 12, left: 22,
            child: IconButton(
              onPressed: () => setState(() => _showLogin = false),
              icon: const Text('‹', style: TextStyle(fontSize: 24, color: T.sub)),
            ),
          ),
        ],
      );

  Widget _socialBtn(Social so) => Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: double.infinity, height: 52,
            child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: so.bg, foregroundColor: so.fg,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(T.radiusSocial)),
              ),
              child: Text(so.label,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
          if (so.last)
            Positioned(
              right: 14, top: -9,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: const BoxDecoration(
                  color: T.lastLogin,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(99), topRight: Radius.circular(99),
                    bottomRight: Radius.circular(99), bottomLeft: Radius.circular(3),
                  ),
                ),
                child: const Text('마지막 로그인',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
        ],
      );
}
