// Copyright (c) 2026 hyunaeee · MIT License — see /LICENSE at the project root.
// ─────────────────────────────────────────────────────────────
// finance_home.dart — 금융 홈 · 토스 스타일 (Flutter)
// 용도: 자산 리스트(탭 → 바텀시트), 주간 소비 바 차트, 주식 리스트, 5탭 탭바
// 실행: https://dartpad.dev 새 Flutter 스니펫에 파일 전체를 붙여넣고 Run
//       (flutter/material.dart 만 사용 — 외부 패키지 없음)
// 토큰: exports/tokens/finance.tokens.json 과 1:1 대응 (class T)
// ─────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

void main() => runApp(const FinanceApp());

/* ── 디자인 토큰 (finance.tokens.json) ── */
class T {
  static const primary = Color(0xFF3182F6); // color.primary — 브랜드 블루
  static const bg = Color(0xFFF2F4F6); //      color.background
  static const surface = Color(0xFFFFFFFF); // color.surface
  static const ink = Color(0xFF191F28); //     color.text-primary
  static const sub = Color(0xFF8B95A1); //     color.text-secondary
  static const negative = Color(0xFFF04452); // color.negative — 상승(국내 관례)/경고
  static const track = Color(0xFFE5E8EB); //   color.chart-track
  static const double radiusCard = 20; //      radius.card
  static const double radiusButton = 14; //    radius.button
  static const double radiusSheet = 28; //     radius.sheet
}

class Account {
  const Account(this.icon, this.iconBg, this.name, this.amount);
  final String icon;
  final Color iconBg;
  final String name;
  final String amount; // "2,483,000"
}

const kAccounts = [
  Account('🏦', Color(0xFFE8F3FF), '토스뱅크 통장', '2,483,000'),
  Account('🐷', Color(0xFFFFF3E0), '비상금 저금통', '518,200'),
  Account('📈', Color(0xFFEEF4FF), '증권 계좌', '7,214,850'),
];

class Spend {
  const Spend(this.day, this.pct, [this.hot = false]);
  final String day;
  final double pct;
  final bool hot;
}

const kSpendWeek = [
  Spend('월', .38), Spend('화', .62), Spend('수', .30), Spend('목', .88, true),
  Spend('금', .46), Spend('토', .20), Spend('일', .12),
];

class Stock {
  const Stock(this.logo, this.logoBg, this.name, this.price, this.delta, this.up);
  final String logo, name, price, delta;
  final Color logoBg;
  final bool up;
}

const kStocks = [
  Stock('A', Color(0xFF1A1A1A), '애플', '312,400원', '+2.4%', true),
  Stock('N', Color(0xFF3182F6), '엔비디아', '198,750원', '+5.1%', true),
  Stock('네', Color(0xFF03C75A), '네이버', '224,000원', '-0.8%', false),
];

const kTabs = [('🏠', '홈'), ('🎁', '혜택'), ('💸', '토스페이'), ('📊', '증권'), ('☰', '전체')];

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: T.bg),
        home: const FinanceHome(),
      );
}

class FinanceHome extends StatefulWidget {
  const FinanceHome({super.key});

  @override
  State<FinanceHome> createState() => _FinanceHomeState();
}

class _FinanceHomeState extends State<FinanceHome> {
  int _tab = 0;

  /* 계좌 탭 → 바텀시트 (원본: .sheet-open 클래스 토글) */
  void _openSheet(Account a) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: T.surface,
      barrierColor: const Color(0x80191F28), // rgba(25,31,40,.5)
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(T.radiusSheet)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44, height: 5,
                decoration: BoxDecoration(color: T.track, borderRadius: BorderRadius.circular(99)),
              ),
            ),
            const SizedBox(height: 18),
            Text(a.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: T.ink)),
            const SizedBox(height: 6),
            Text.rich(TextSpan(
              text: '잔액 ',
              style: const TextStyle(fontSize: 13.5, color: T.sub),
              children: [
                TextSpan(text: a.amount, style: const TextStyle(fontWeight: FontWeight.w700)),
                const TextSpan(text: '원'),
              ],
            )),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: _sheetBtn(ctx, '내역 보기', T.bg, T.ink)),
              const SizedBox(width: 10),
              Expanded(child: _sheetBtn(ctx, '송금', T.primary, Colors.white)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _sheetBtn(BuildContext ctx, String label, Color bg, Color fg) => FilledButton(
        onPressed: () => Navigator.of(ctx).pop(),
        style: FilledButton.styleFrom(
          backgroundColor: bg, foregroundColor: fg,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(T.radiusButton)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          // ── 앱 헤더 ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(children: [
              const Text('toss',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: T.primary, letterSpacing: -.5)),
              const Spacer(),
              const Text('💬', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 16),
              Stack(clipBehavior: Clip.none, children: [
                const Text('🔔', style: TextStyle(fontSize: 18)),
                Positioned(
                  top: 0, right: -2,
                  child: Container(width: 7, height: 7,
                      decoration: const BoxDecoration(color: T.negative, shape: BoxShape.circle)),
                ),
              ]),
            ]),
          ),
          // ── 본문 스크롤 ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 100),
              children: [
                _card([
                  _secTitle('자산', '순서 편집'),
                  for (final a in kAccounts) _acctRow(a),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: T.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(T.radiusButton)),
                      ),
                      child: const Text('송금하기', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ]),
                _card([
                  _secTitle('이번 주 소비', '7월 6일 ~ 오늘'),
                  const SizedBox(height: 6),
                  const Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('184,300원',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: T.ink, letterSpacing: -.5)),
                    SizedBox(width: 8),
                    Padding(
                      padding: EdgeInsets.only(bottom: 3),
                      child: Text('지난주보다 12% ↓',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: T.negative)),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _weekBars(),
                ]),
                _card([
                  _secTitle('내 주식', '실시간'),
                  for (final st in kStocks) _stockRow(st),
                ]),
              ],
            ),
          ),
        ]),
      ),
      // ── 5탭 탭바 ──
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xF2FFFFFF),
          border: Border(top: BorderSide(color: Color(0xFFEEF0F3))),
        ),
        padding: const EdgeInsets.only(top: 8, bottom: 22, left: 6, right: 6),
        child: Row(
          children: [
            for (var i = 0; i < kTabs.length; i++)
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _tab = i),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Opacity(opacity: _tab == i ? 1 : .4,
                        child: Text(kTabs[i].$1, style: const TextStyle(fontSize: 21))),
                    const SizedBox(height: 3),
                    Text(kTabs[i].$2,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: _tab == i ? FontWeight.w700 : FontWeight.w500,
                          color: _tab == i ? T.ink : const Color(0xFFB0B8C1),
                        )),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: BoxDecoration(color: T.surface, borderRadius: BorderRadius.circular(T.radiusCard)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );

  Widget _secTitle(String title, String action) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: T.ink)),
          Text(action, style: const TextStyle(fontSize: 12.5, color: T.sub)),
        ],
      );

  Widget _acctRow(Account a) => InkWell(
        onTap: () => _openSheet(a),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
          child: Row(children: [
            Container(
              width: 40, height: 40, alignment: Alignment.center,
              decoration: BoxDecoration(color: a.iconBg, borderRadius: BorderRadius.circular(14)),
              child: Text(a.icon, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(a.name, style: const TextStyle(fontSize: 13, color: T.sub)),
                Text('${a.amount}원',
                    style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700, color: T.ink, letterSpacing: -.3)),
              ]),
            ),
            const Text('›', style: TextStyle(fontSize: 16, color: Color(0xFFD1D6DB))),
          ]),
        ),
      );

  /* 주간 소비 바 차트 — 원본 @keyframes grow 를 TweenAnimationBuilder 로 재현 */
  Widget _weekBars() => SizedBox(
        height: 92,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < kSpendWeek.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => Container(
                      height: 74 * kSpendWeek[i].pct * v,
                      decoration: BoxDecoration(
                        color: kSpendWeek[i].hot ? T.primary : T.track,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(kSpendWeek[i].day, style: const TextStyle(fontSize: 10.5, color: T.sub)),
                ]),
              ),
            ],
          ],
        ),
      );

  Widget _stockRow(Stock st) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
        child: Row(children: [
          CircleAvatar(
            radius: 18, backgroundColor: st.logoBg,
            child: Text(st.logo,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(st.name, style: const TextStyle(fontSize: 14.5, color: T.ink))),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(st.price, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: T.ink)),
            Text(st.delta,
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: st.up ? T.negative : T.primary, // 상승=빨강, 하락=파랑 (국내 관례)
                )),
          ]),
        ]),
      );
}
