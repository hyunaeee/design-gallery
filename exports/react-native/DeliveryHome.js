// Copyright (c) 2026 hyunaeee · MIT License — see /LICENSE at the project root.
/**
 * 배달 홈 — 배민 스타일 (React Native)
 * 의존성: react-native 코어만 사용 — Expo Snack에 그대로 붙여넣어 실행 가능
 * 실제 동작: 자동 순환 배너 캐러셀, 카테고리 그리드, 주문 현황 플로팅 바
 * 토큰: exports/tokens/delivery.tokens.json 과 1:1 대응
 */
import React, { useEffect, useRef, useState } from 'react';
import {
  SafeAreaView, ScrollView, View, Text, Image, Pressable,
  ActivityIndicator, useWindowDimensions, StyleSheet,
} from 'react-native';

/* ── 디자인 토큰 (delivery.tokens.json) ── */
const T = {
  primary: '#2AC1BC', ink: '#1C1C1E', sub: '#8E8E93',
  divider: '#F2F2F7', star: '#FFC400', catBg: '#F7F8FA',
};

const CATS = [
  ['🍗', '치킨'], ['🍕', '피자'], ['🍜', '중식'], ['🍣', '회·초밥'], ['🍔', '버거'],
  ['🥘', '한식'], ['🌮', '양식'], ['🍰', '카페·디저트'], ['🥡', '분식'], ['🌙', '야식'],
];
const BANNERS = [
  { colors: ['#2AC1BC', '#1A9A95'], small: '7월 한정', title: '첫 주문 8,000원 쿠폰팩', emoji: '🎁' },
  { colors: ['#5F27CD', '#8854D0'], small: '한집배달', title: '지금은 피크타임 할인 중', emoji: '⚡' },
  { colors: ['#FF793F', '#FFB142'], small: '장보기·쇼핑', title: '수박 반통 오늘 도착', emoji: '🍉' },
];
const SHOPS = [
  { img: 'https://picsum.photos/id/292/340/220', coupon: '3,000원 쿠폰',
    name: '교촌 허니콤보 강남점', info: '★ 4.9 (2,841) · 15~25분' },
  { img: 'https://picsum.photos/id/1060/340/220',
    name: '피자헤븐 시카고딥디쉬', info: '★ 4.7 (912) · 배달비 무료' },
  { img: 'https://picsum.photos/id/429/340/220', coupon: '신규 오픈',
    name: '스시오마카세 도시락', info: '★ 5.0 (188) · 20~30분' },
];

export default function DeliveryHome() {
  const { width } = useWindowDimensions();
  const bannerW = width - 32;
  const bannerRef = useRef(null);
  const [bi, setBi] = useState(0);

  /* 배너 자동 순환 */
  useEffect(() => {
    const t = setInterval(() => setBi(i => (i + 1) % BANNERS.length), 3200);
    return () => clearInterval(t);
  }, []);
  useEffect(() => {
    bannerRef.current?.scrollTo({ x: bi * bannerW, animated: true });
  }, [bi, bannerW]);

  return (
    <SafeAreaView style={s.root}>
      {/* 브랜드 컬러 헤더 + 검색 */}
      <View style={s.headZone}>
        <Text style={s.addr}>📍 테헤란로 427 <Text style={{ fontSize: 11 }}>▼</Text></Text>
        <Pressable style={s.search}>
          <Text style={{ color: T.primary, fontSize: 16 }}>⌕</Text>
          <Text style={{ color: T.sub, fontSize: 14.5 }}>오늘 뭐 먹지? 치킨 어때요</Text>
        </Pressable>
      </View>

      <ScrollView contentContainerStyle={{ paddingBottom: 120 }}>
        {/* 카테고리 그리드 (5열) */}
        <View style={s.cats}>
          {CATS.map(([emoji, label]) => (
            <Pressable key={label} style={s.cat}>
              <View style={s.catIcon}><Text style={{ fontSize: 24 }}>{emoji}</Text></View>
              <Text style={s.catLabel}>{label}</Text>
            </Pressable>
          ))}
        </View>

        {/* 프로모 배너 캐러셀 */}
        <View style={{ marginHorizontal: 16, borderRadius: 16, overflow: 'hidden' }}>
          <ScrollView ref={bannerRef} horizontal pagingEnabled scrollEnabled={false}
                      showsHorizontalScrollIndicator={false}>
            {BANNERS.map(b => (
              <View key={b.title} style={[s.banner, { width: bannerW, backgroundColor: b.colors[0] }]}>
                <Text style={s.bannerSmall}>{b.small}</Text>
                <Text style={s.bannerTitle}>{b.title}</Text>
                <Text style={s.bannerEmoji}>{b.emoji}</Text>
              </View>
            ))}
          </ScrollView>
          <View style={s.dots}>
            {BANNERS.map((_, i) => (
              <View key={i} style={[s.dot, bi === i && { backgroundColor: '#fff' }]} />
            ))}
          </View>
        </View>

        {/* 인기 가게 가로 카드 */}
        <View style={s.secHead}>
          <Text style={s.secTitle}>우리 동네 인기 맛집</Text>
          <Text style={{ fontSize: 12.5, color: T.sub }}>전체보기 ›</Text>
        </View>
        <ScrollView horizontal showsHorizontalScrollIndicator={false}
                    contentContainerStyle={{ gap: 12, paddingHorizontal: 16 }}>
          {SHOPS.map(shop => (
            <Pressable key={shop.name} style={{ width: 168 }}>
              <View style={s.shopPh}>
                <Image source={{ uri: shop.img }} style={StyleSheet.absoluteFillObject} />
                {shop.coupon && <Text style={s.coupon}>{shop.coupon}</Text>}
              </View>
              <Text style={s.shopName}>{shop.name}</Text>
              <Text style={s.shopInfo}>{shop.info}</Text>
            </Pressable>
          ))}
        </ScrollView>
      </ScrollView>

      {/* 주문 현황 플로팅 바 (라이브 액티비티) */}
      <View style={s.orderBar}>
        <ActivityIndicator color={T.primary} size="small" />
        <View style={{ flex: 1 }}>
          <Text style={s.orderTitle}>교촌 허니콤보 배달 중</Text>
          <Text style={s.orderSub}>라이더가 음식을 픽업했어요</Text>
        </View>
        <Text style={s.eta}>12분</Text>
      </View>
    </SafeAreaView>
  );
}

const s = StyleSheet.create({
  root: { flex: 1, backgroundColor: '#fff' },
  headZone: { backgroundColor: T.primary, paddingBottom: 18 },
  addr: { color: '#fff', fontSize: 16.5, fontWeight: '900', paddingHorizontal: 20, paddingTop: 8 },
  search: { flexDirection: 'row', alignItems: 'center', gap: 10, marginHorizontal: 18, marginTop: 14,
            backgroundColor: '#fff', borderRadius: 14, paddingHorizontal: 16, paddingVertical: 13,
            shadowColor: '#000', shadowOpacity: .08, shadowRadius: 7, shadowOffset: { width: 0, height: 4 },
            elevation: 3 },
  cats: { flexDirection: 'row', flexWrap: 'wrap', paddingHorizontal: 16, paddingTop: 20 },
  cat: { width: '20%', alignItems: 'center', gap: 7, marginBottom: 16 },
  catIcon: { width: 52, height: 52, borderRadius: 18, backgroundColor: T.catBg,
             alignItems: 'center', justifyContent: 'center' },
  catLabel: { fontSize: 11.5, color: '#3A3A3C' },
  banner: { minHeight: 96, padding: 20, justifyContent: 'center' },
  bannerSmall: { color: '#fff', fontSize: 12, opacity: .9 },
  bannerTitle: { color: '#fff', fontSize: 18, fontWeight: '900', marginTop: 4 },
  bannerEmoji: { position: 'absolute', right: 18, bottom: 12, fontSize: 40 },
  dots: { position: 'absolute', right: 12, bottom: 10, flexDirection: 'row', gap: 5 },
  dot: { width: 6, height: 6, borderRadius: 3, backgroundColor: 'rgba(255,255,255,.45)' },
  secHead: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'baseline',
             paddingHorizontal: 18, paddingTop: 26, paddingBottom: 12 },
  secTitle: { fontSize: 17, fontWeight: '900', color: T.ink },
  shopPh: { height: 108, borderRadius: 14, overflow: 'hidden', backgroundColor: T.divider },
  coupon: { position: 'absolute', left: 8, top: 8, backgroundColor: T.ink, color: '#fff',
            fontSize: 10.5, fontWeight: '700', paddingHorizontal: 8, paddingVertical: 3.5,
            borderRadius: 7, overflow: 'hidden' },
  shopName: { marginTop: 9, fontSize: 14, fontWeight: '700', color: T.ink },
  shopInfo: { marginTop: 3, fontSize: 12, color: T.sub },
  orderBar: { position: 'absolute', left: 14, right: 14, bottom: 24, flexDirection: 'row',
              alignItems: 'center', gap: 12, backgroundColor: T.ink, borderRadius: 16,
              paddingHorizontal: 16, paddingVertical: 13,
              shadowColor: '#000', shadowOpacity: .35, shadowRadius: 15,
              shadowOffset: { width: 0, height: 14 }, elevation: 10 },
  orderTitle: { color: '#fff', fontSize: 14, fontWeight: '700' },
  orderSub: { color: '#ffffffb0', fontSize: 12.5 },
  eta: { color: T.primary, fontSize: 15, fontWeight: '900' },
});
