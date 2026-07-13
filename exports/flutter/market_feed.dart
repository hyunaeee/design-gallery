// Copyright (c) 2026 hyunaeee · MIT License — see /LICENSE at the project root.
// ─────────────────────────────────────────────────────────────
// market_feed.dart — 중고거래 피드 · 당근 스타일 (Flutter)
// 용도: 동네 셀렉터 헤더, 칩 필터, 썸네일 리스트, 스크롤 시 접히는 확장형 FAB
// 실행: https://dartpad.dev 새 Flutter 스니펫에 파일 전체를 붙여넣고 Run
//       (flutter/material.dart + dart:async 만 사용 — 외부 패키지 없음)
// 토큰: exports/tokens/market.tokens.json 과 1:1 대응 (class T)
// ─────────────────────────────────────────────────────────────
import 'dart:async';

import 'package:flutter/material.dart';

void main() => runApp(const MarketApp());

/* ── 디자인 토큰 (market.tokens.json) ── */
class T {
  static const primary = Color(0xFFFF6F0F); //   color.primary — 당근 오렌지
  static const bg = Color(0xFFFFFFFF); //        color.background
  static const ink = Color(0xFF212124); //       color.text-primary
  static const sub = Color(0xFF868B94); //       color.text-secondary
  static const divider = Color(0xFFF1F3F5); //   color.divider
  static const chipBorder = Color(0xFFE9ECEF); // color.chip-border
  static const reserved = Color(0xFF1D7D45); //  color.reserved — 예약중 뱃지
  static const double radiusThumb = 12; //       radius.thumbnail
  static const double thumbSize = 108; //        component.thumbnail-size
  static const double fabHeight = 54; //         component.fab-height
}

class MarketItem {
  const MarketItem({
    required this.img, required this.emoji, required this.fallback,
    required this.title, required this.area, required this.price,
    this.reserved = false, this.free = false,
    required this.likes, required this.chats,
  });
  final String img, emoji, title, area, price;
  final List<Color> fallback;
  final bool reserved, free;
  final int likes, chats;
}

const kChips = ['전체', '디지털기기', '가구/인테리어', '유아동', '생활가전', '의류'];

const kItems = [
  MarketItem(img: 'https://picsum.photos/id/119/220/220', emoji: '💻',
      fallback: [Color(0xFFDFE9F3), Color(0xFFFFFFFF)],
      title: '맥북 프로 14인치 M3 급처합니다', area: '역삼동 · 10분 전',
      price: '1,850,000원', likes: 12, chats: 5),
  MarketItem(img: 'https://picsum.photos/id/1080/220/220', emoji: '🪑',
      fallback: [Color(0xFFFBE9D7), Color(0xFFF6D5B8)], reserved: true,
      title: '원목 식탁 4인용 + 의자 세트', area: '대치동 · 32분 전',
      price: '120,000원', likes: 28, chats: 11),
  MarketItem(img: 'https://picsum.photos/id/96/220/220', emoji: '🌱',
      fallback: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)], free: true,
      title: '몬스테라 대품 화분째로 드려요', area: '도곡동 · 1시간 전',
      price: '나눔 🧡', likes: 41, chats: 23),
  MarketItem(img: 'https://picsum.photos/id/175/220/220', emoji: '📷',
      fallback: [Color(0xFFEDE7F6), Color(0xFFD1C4E9)],
      title: '필름카메라 캐논 AE-1 작동 완벽', area: '역삼동 · 2시간 전',
      price: '230,000원', likes: 19, chats: 7),
  MarketItem(img: 'https://picsum.photos/id/21/220/220', emoji: '👟',
      fallback: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
      title: '나이키 에어포스 270 새상품 (박스풀)', area: '삼성동 · 3시간 전',
      price: '89,000원', likes: 8, chats: 2),
];

const kTabs = [('🏠', '홈'), ('🗞️', '동네생활'), ('📍', '내 근처'), ('💬', '채팅'), ('👤', '나의 당근')];

class MarketApp extends StatelessWidget {
  const MarketApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: T.bg),
        home: const MarketFeed(),
      );
}

class MarketFeed extends StatefulWidget {
  const MarketFeed({super.key});

  @override
  State<MarketFeed> createState() => _MarketFeedState();
}

class _MarketFeedState extends State<MarketFeed> {
  int _chip = 0;
  int _tab = 0;
  bool _fabWide = true; // 스크롤 중 false → 350ms 멈추면 true (원본 HTML 동작)
  Timer? _fabTimer;

  @override
  void dispose() {
    _fabTimer?.cancel();
    super.dispose();
  }

  /* NotificationListener 로 스크롤 감지 → FAB 접힘/펼침 */
  bool _onScroll(ScrollNotification n) {
    if (n is ScrollUpdateNotification) {
      if (_fabWide) setState(() => _fabWide = false);
      _fabTimer?.cancel();
      _fabTimer = Timer(const Duration(milliseconds: 350), () {
        if (mounted) setState(() => _fabWide = true);
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          // ── 헤더: 동네 셀렉터 + 아이콘(채팅 뱃지 3) ──
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
            child: Row(children: [
              const Text('역삼동', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: T.ink)),
              const SizedBox(width: 5),
              const Text('▼', style: TextStyle(fontSize: 12, color: T.sub)),
              const Spacer(),
              const Text('🔍', style: TextStyle(fontSize: 19)),
              const SizedBox(width: 17),
              Stack(clipBehavior: Clip.none, children: [
                const Text('💬', style: TextStyle(fontSize: 19)),
                Positioned(
                  top: -5, right: -8,
                  child: Container(
                    width: 16, height: 16, alignment: Alignment.center,
                    decoration: const BoxDecoration(color: T.primary, shape: BoxShape.circle),
                    child: const Text('3',
                        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ]),
              const SizedBox(width: 17),
              const Text('🔔', style: TextStyle(fontSize: 19)),
            ]),
          ),
          // ── 칩 필터 ──
          Container(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: T.divider))),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
              child: Row(children: [
                for (var i = 0; i < kChips.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  _chipBtn(i),
                ],
              ]),
            ),
          ),
          // ── 피드 리스트 (스크롤 → FAB 접힘) ──
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 90),
                itemCount: kItems.length,
                itemBuilder: (_, i) => _feedCell(kItems[i]),
              ),
            ),
          ),
        ]),
      ),
      // ── 확장형 FAB: 라벨이 AnimatedSize 로 접힘 ──
      floatingActionButton: Material(
        color: T.primary,
        borderRadius: BorderRadius.circular(99),
        elevation: 8,
        shadowColor: T.primary.withOpacity(.45),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(99),
          child: Container(
            height: T.fabHeight,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Text('＋', style: TextStyle(fontSize: 21, color: Colors.white)),
              AnimatedSize(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                child: _fabWide
                    ? const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text('글쓰기',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                      )
                    : const SizedBox.shrink(),
              ),
            ]),
          ),
        ),
      ),
      // ── 5탭 탭바 ──
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
                        color: _tab == i ? T.ink : const Color(0xFFB0B8C1),
                      )),
                ]),
              ),
            ),
        ]),
      ),
    );
  }

  Widget _chipBtn(int i) {
    final on = _chip == i;
    return InkWell(
      onTap: () => setState(() => _chip = i),
      borderRadius: BorderRadius.circular(99),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: on ? T.ink : Colors.white,
          border: Border.all(color: on ? T.ink : T.chipBorder),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(kChips[i],
            style: TextStyle(
              fontSize: 13,
              fontWeight: on ? FontWeight.w700 : FontWeight.w500,
              color: on ? Colors.white : const Color(0xFF4D5159),
            )),
      ),
    );
  }

  /* 리스트 셀 — 썸네일(이미지 실패 시 이모지 폴백) + 제목/메타/가격/카운트 */
  Widget _feedCell(MarketItem item) => InkWell(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: T.divider))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(T.radiusThumb),
              child: SizedBox(
                width: T.thumbSize, height: T.thumbSize,
                child: Stack(fit: StackFit.expand, children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: item.fallback,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(item.emoji, style: const TextStyle(fontSize: 38)),
                  ),
                  Image.network(item.img, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                ]),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: T.thumbSize,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text.rich(
                    TextSpan(children: [
                      if (item.reserved)
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Container(
                            margin: const EdgeInsets.only(right: 5),
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                                color: T.reserved, borderRadius: BorderRadius.circular(5)),
                            child: const Text('예약중',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                        ),
                      TextSpan(text: item.title),
                    ]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, height: 1.4, color: T.ink),
                  ),
                  const SizedBox(height: 4),
                  Text(item.area, style: const TextStyle(fontSize: 12.5, color: T.sub)),
                  const SizedBox(height: 5),
                  Text(item.price,
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w900,
                        color: item.free ? T.primary : T.ink,
                      )),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text('♡ ${item.likes}   💬 ${item.chats}',
                        style: const TextStyle(fontSize: 12, color: T.sub)),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      );
}
