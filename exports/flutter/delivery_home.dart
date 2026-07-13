// Copyright (c) 2026 hyunaeee · MIT License — see /LICENSE at the project root.
// ─────────────────────────────────────────────────────────────
// delivery_home.dart — 배달 홈 · 배민 스타일 (Flutter)
// 용도: 민트 헤더+검색바, 카테고리 그리드(5열), 자동 순환 배너 캐러셀,
//       가로 스크롤 가게 카드, 주문 현황 플로팅 바, 5탭 탭바
// 실행: https://dartpad.dev 새 Flutter 스니펫에 파일 전체를 붙여넣고 Run
//       (flutter/material.dart + dart:async 만 사용 — 외부 패키지 없음)
// 토큰: exports/tokens/delivery.tokens.json 과 1:1 대응 (class T)
// ─────────────────────────────────────────────────────────────
import 'dart:async';

import 'package:flutter/material.dart';

void main() => runApp(const DeliveryApp());

/* ── 디자인 토큰 (delivery.tokens.json) ── */
class T {
  static const primary = Color(0xFF2AC1BC); //  color.primary — 브랜드 민트
  static const bg = Color(0xFFFFFFFF); //       color.background
  static const ink = Color(0xFF1C1C1E); //      color.text-primary / order-bar
  static const sub = Color(0xFF8E8E93); //      color.text-secondary
  static const divider = Color(0xFFF2F2F7); //  color.divider
  static const star = Color(0xFFFFC400); //     color.star
  static const catBg = Color(0xFFF7F8FA); //    color.category-bg
  static const double radiusSearch = 14; //     radius.search
  static const double radiusBanner = 16; //     radius.banner
  static const double radiusCard = 14; //       radius.card
  static const double radiusCategory = 18; //   radius.category
  static const double bannerHeight = 96; //     component.banner-height
  static const double shopCardWidth = 168; //   component.shop-card-width
}

const kCats = [
  ('🍗', '치킨'), ('🍕', '피자'), ('🍜', '중식'), ('🍣', '회·초밥'), ('🍔', '버거'),
  ('🥘', '한식'), ('🌮', '양식'), ('🍰', '카페·디저트'), ('🥡', '분식'), ('🌙', '야식'),
];

class Banner3 {
  const Banner3(this.colors, this.small, this.title, this.emoji);
  final List<Color> colors;
  final String small, title, emoji;
}

const kBanners = [
  Banner3([Color(0xFF2AC1BC), Color(0xFF1A9A95)], '7월 한정', '첫 주문 8,000원 쿠폰팩', '🎁'),
  Banner3([Color(0xFF5F27CD), Color(0xFF8854D0)], '한집배달', '지금은 피크타임 할인 중', '⚡'),
  Banner3([Color(0xFFFF793F), Color(0xFFFFB142)], '장보기·쇼핑', '수박 반통 오늘 도착', '🍉'),
];

class Shop {
  const Shop({this.img, required this.emoji, required this.fallback,
      this.coupon, required this.name, required this.info});
  final String? img;
  final String emoji;
  final List<Color> fallback;
  final String? coupon;
  final String name, info;
}

const kHotShops = [
  Shop(img: 'https://picsum.photos/id/292/340/220', emoji: '🍗',
      fallback: [Color(0xFFFFE8D6), Color(0xFFFFD3A8)], coupon: '3,000원 쿠폰',
      name: '교촌 허니콤보 강남점', info: '(2,841) · 15~25분'),
  Shop(img: 'https://picsum.photos/id/1060/340/220', emoji: '🍕',
      fallback: [Color(0xFFFFE0E0), Color(0xFFFFC9C9)],
      name: '피자헤븐 시카고딥디쉬', info: '(912) · 배달비 무료'),
  Shop(img: 'https://picsum.photos/id/429/340/220', emoji: '🍣',
      fallback: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)], coupon: '신규 오픈',
      name: '스시오마카세 도시락', info: '(188) · 20~30분'),
];
const kHotStars = ['★ 4.9', '★ 4.7', '★ 5.0'];

const kMartShops = [
  Shop(emoji: '🧺', fallback: [Color(0xFFD4FC79), Color(0xFF96E6A1)],
      name: '장보기 30분 배달', info: '과일·정육·생필품'),
  Shop(emoji: '💊', fallback: [Color(0xFFA1C4FD), Color(0xFFC2E9FB)],
      name: '새벽 안전상비약', info: '24시간 · 즉시 배달'),
];

const kTabs = [('🏠', '홈'), ('🔍', '검색'), ('🧾', '주문내역'), ('❤️', '찜'), ('👤', '마이배민')];

class DeliveryApp extends StatelessWidget {
  const DeliveryApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: T.bg),
        home: const DeliveryHome(),
      );
}

class DeliveryHome extends StatefulWidget {
  const DeliveryHome({super.key});

  @override
  State<DeliveryHome> createState() => _DeliveryHomeState();
}

class _DeliveryHomeState extends State<DeliveryHome> {
  final _pageCtrl = PageController();
  Timer? _bannerTimer;
  int _bi = 0;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    /* 배너 자동 순환 — 원본 setInterval 3200ms 재현 */
    _bannerTimer = Timer.periodic(const Duration(milliseconds: 3200), (_) {
      if (!_pageCtrl.hasClients) return;
      final next = (_bi + 1) % kBanners.length;
      _pageCtrl.animateToPage(next,
          duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Column(children: [
          // ── 민트 헤더: 주소 + 검색바 ──
          Container(
            color: T.primary,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 6, 20, 0),
                child: Text('📍 테헤란로 427 ▼',
                    style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(T.radiusSearch),
                  boxShadow: const [
                    BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 4)),
                  ],
                ),
                child: const Row(children: [
                  Text('⌕', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: T.primary)),
                  SizedBox(width: 10),
                  Text('오늘 뭐 먹지? 치킨 어때요', style: TextStyle(fontSize: 14.5, color: T.sub)),
                ]),
              ),
            ]),
          ),
          // ── 본문 스크롤 ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 160),
              children: [
                // 카테고리 그리드 (5열)
                GridView.count(
                  crossAxisCount: 5,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 6,
                  childAspectRatio: .82,
                  children: [
                    for (final (emoji, label) in kCats)
                      Column(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                          width: 52, height: 52, alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: T.catBg, borderRadius: BorderRadius.circular(T.radiusCategory)),
                          child: Text(emoji, style: const TextStyle(fontSize: 25)),
                        ),
                        const SizedBox(height: 7),
                        Text(label,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF3A3A3C))),
                      ]),
                  ],
                ),
                // 자동 순환 배너 캐러셀 + dots
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(T.radiusBanner),
                    child: SizedBox(
                      height: T.bannerHeight,
                      child: Stack(children: [
                        PageView(
                          controller: _pageCtrl,
                          onPageChanged: (i) => setState(() => _bi = i),
                          children: [for (final b in kBanners) _banner(b)],
                        ),
                        Positioned(
                          right: 12, bottom: 10,
                          child: Row(children: [
                            for (var i = 0; i < kBanners.length; i++) ...[
                              if (i > 0) const SizedBox(width: 5),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 6, height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: i == _bi ? Colors.white : Colors.white.withOpacity(.45),
                                ),
                              ),
                            ],
                          ]),
                        ),
                      ]),
                    ),
                  ),
                ),
                _secHead('우리 동네 인기 맛집'),
                _shopRow(kHotShops, stars: kHotStars),
                _secHead('이럴 때 배민 B마트'),
                _shopRow(kMartShops),
              ],
            ),
          ),
        ]),
        // ── 주문 현황 플로팅 바 (라이브 액티비티) ──
        Positioned(
          left: 14, right: 14, bottom: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: T.ink,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Color(0x59000000), blurRadius: 30, offset: Offset(0, 14))],
            ),
            child: const Row(children: [
              SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: T.primary, backgroundColor: Color(0x40FFFFFF)),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('교촌 허니콤보 배달 중',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                  Text('라이더가 음식을 픽업했어요',
                      style: TextStyle(fontSize: 12.5, color: Color(0xB0FFFFFF))),
                ]),
              ),
              Text('12분', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: T.primary)),
            ]),
          ),
        ),
      ]),
      // ── 5탭 탭바 (활성 = 민트) ──
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xF5FFFFFF),
          border: Border(top: BorderSide(color: T.divider)),
        ),
        padding: const EdgeInsets.only(top: 8, bottom: 22, left: 6, right: 6),
        child: Row(children: [
          for (var i = 0; i < kTabs.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _tab = i),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Opacity(opacity: _tab == i ? 1 : .4,
                      child: Text(kTabs[i].$1, style: const TextStyle(fontSize: 20))),
                  const SizedBox(height: 3),
                  Text(kTabs[i].$2,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: _tab == i ? FontWeight.w700 : FontWeight.w500,
                        color: _tab == i ? T.primary : const Color(0xFFB0B8C1),
                      )),
                ]),
              ),
            ),
        ]),
      ),
    );
  }

  Widget _banner(Banner3 b) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerLeft, end: Alignment.bottomRight, colors: b.colors),
        ),
        child: Stack(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(b.small, style: const TextStyle(fontSize: 12, color: Color(0xE6FFFFFF))),
            const SizedBox(height: 4),
            Text(b.title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -.3)),
          ]),
          Positioned(right: 0, bottom: -6, child: Text(b.emoji, style: const TextStyle(fontSize: 42))),
        ]),
      );

  Widget _secHead(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 26, 18, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: T.ink, letterSpacing: -.3)),
            const Text('전체보기 ›', style: TextStyle(fontSize: 12.5, color: T.sub)),
          ],
        ),
      );

  /* 가로 스크롤 가게 카드 (이미지 실패 시 이모지 폴백, 쿠폰 뱃지, 별점) */
  Widget _shopRow(List<Shop> shops, {List<String>? stars}) => SizedBox(
        height: 172,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: shops.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final shop = shops[i];
            return SizedBox(
              width: T.shopCardWidth,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(T.radiusCard),
                  child: SizedBox(
                    height: 108,
                    width: double.infinity,
                    child: Stack(fit: StackFit.expand, children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft, end: Alignment.bottomRight,
                              colors: shop.fallback),
                        ),
                        alignment: Alignment.center,
                        child: Text(shop.emoji, style: const TextStyle(fontSize: 40)),
                      ),
                      if (shop.img != null)
                        Image.network(shop.img!, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                      if (shop.coupon != null)
                        Positioned(
                          left: 8, top: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                            decoration: BoxDecoration(
                                color: T.ink, borderRadius: BorderRadius.circular(7)),
                            child: Text(shop.coupon!,
                                style: const TextStyle(
                                    fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                        ),
                    ]),
                  ),
                ),
                const SizedBox(height: 9),
                Text(shop.name,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: T.ink)),
                const SizedBox(height: 3),
                Text.rich(
                  TextSpan(children: [
                    if (stars != null)
                      TextSpan(
                          text: '${stars[i]} ',
                          style: const TextStyle(color: T.star, fontWeight: FontWeight.w700)),
                    TextSpan(text: shop.info),
                  ]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: T.sub),
                ),
              ]),
            );
          },
        ),
      );
}
