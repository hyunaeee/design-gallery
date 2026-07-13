// Copyright (c) 2026 hyunaeee · MIT License — see /LICENSE at the project root.
/**
 * 중고거래 피드 — 당근 스타일 (React Native)
 * 의존성: react-native 코어만 사용 — Expo Snack에 그대로 붙여넣어 실행 가능
 * 실제 동작: 스크롤 시 FAB 접힘/펼침(Animated), 칩 필터, 하트 카운트
 * 토큰: exports/tokens/market.tokens.json 과 1:1 대응
 */
import React, { useRef, useState } from 'react';
import {
  SafeAreaView, FlatList, ScrollView, View, Text, Image, Pressable,
  Animated, StyleSheet,
} from 'react-native';

/* ── 디자인 토큰 (market.tokens.json) ── */
const T = {
  primary: '#FF6F0F', ink: '#212124', sub: '#868B94',
  divider: '#F1F3F5', chipBorder: '#E9ECEF', reserved: '#1D7D45',
  radiusThumb: 12, thumbSize: 108,
};

const CHIPS = ['전체', '디지털기기', '가구/인테리어', '유아동', '생활가전', '의류'];
const ITEMS = [
  { id: '1', img: 'https://picsum.photos/id/119/220/220', emoji: '💻',
    title: '맥북 프로 14인치 M3 급처합니다', area: '역삼동 · 10분 전', price: '1,850,000원', likes: 12, chats: 5 },
  { id: '2', img: 'https://picsum.photos/id/1080/220/220', emoji: '🪑', reserved: true,
    title: '원목 식탁 4인용 + 의자 세트', area: '대치동 · 32분 전', price: '120,000원', likes: 28, chats: 11 },
  { id: '3', img: 'https://picsum.photos/id/96/220/220', emoji: '🌱',
    title: '몬스테라 대품 화분째로 드려요', area: '도곡동 · 1시간 전', price: '나눔 🧡', free: true, likes: 41, chats: 23 },
  { id: '4', img: 'https://picsum.photos/id/175/220/220', emoji: '📷',
    title: '필름카메라 캐논 AE-1 작동 완벽', area: '역삼동 · 2시간 전', price: '230,000원', likes: 19, chats: 7 },
  { id: '5', img: 'https://picsum.photos/id/21/220/220', emoji: '👟',
    title: '나이키 에어포스 270 새상품 (박스풀)', area: '삼성동 · 3시간 전', price: '89,000원', likes: 8, chats: 2 },
];

export default function MarketFeed() {
  const [chip, setChip] = useState(0);
  const fabWidth = useRef(new Animated.Value(1)).current;  // 1 = 펼침, 0 = 접힘
  const fabTimer = useRef(null);

  /* 스크롤 중 접힘 → 350ms 멈추면 펼침 (원본 HTML 데모와 동일한 동작) */
  const onScroll = () => {
    Animated.timing(fabWidth, { toValue: 0, duration: 200, useNativeDriver: false }).start();
    clearTimeout(fabTimer.current);
    fabTimer.current = setTimeout(() =>
      Animated.timing(fabWidth, { toValue: 1, duration: 300, useNativeDriver: false }).start(), 350);
  };

  const renderItem = ({ item }) => (
    <Pressable style={({ pressed }) => [s.cell, pressed && { backgroundColor: '#FAFAFA' }]}>
      <View style={s.thumb}>
        <Image source={{ uri: item.img }} style={s.thumbImg} />
        <Text style={s.thumbEmoji}>{item.emoji}</Text>
      </View>
      <View style={{ flex: 1 }}>
        <Text style={s.title} numberOfLines={2}>
          {item.reserved && <Text style={s.reserved}> 예약중 </Text>}
          {item.reserved ? ' ' : ''}{item.title}
        </Text>
        <Text style={s.meta}>{item.area}</Text>
        <Text style={[s.price, item.free && { color: T.primary }]}>{item.price}</Text>
        <Text style={s.counts}>♡ {item.likes}   💬 {item.chats}</Text>
      </View>
    </Pressable>
  );

  return (
    <SafeAreaView style={s.root}>
      {/* 헤더: 동네 셀렉터 */}
      <View style={s.head}>
        <Text style={s.loc}>역삼동 <Text style={{ fontSize: 12, color: T.sub }}>▼</Text></Text>
        <View style={{ flexDirection: 'row', gap: 17 }}>
          <Text style={s.hIcon}>🔍</Text>
          <View><Text style={s.hIcon}>💬</Text><View style={s.chatBadge}><Text style={s.chatBadgeText}>3</Text></View></View>
          <Text style={s.hIcon}>🔔</Text>
        </View>
      </View>

      {/* 칩 필터 */}
      <View style={{ borderBottomWidth: 1, borderBottomColor: T.divider }}>
        <ScrollView horizontal showsHorizontalScrollIndicator={false}
                    contentContainerStyle={{ gap: 8, paddingHorizontal: 18, paddingBottom: 12 }}>
          {CHIPS.map((c, i) => (
            <Pressable key={c} onPress={() => setChip(i)}
              style={[s.chip, chip === i && s.chipOn]}>
              <Text style={[s.chipText, chip === i && s.chipTextOn]}>{c}</Text>
            </Pressable>
          ))}
        </ScrollView>
      </View>

      <FlatList data={ITEMS} keyExtractor={i => i.id} renderItem={renderItem}
                onScroll={onScroll} scrollEventThrottle={64}
                contentContainerStyle={{ paddingBottom: 90 }} />

      {/* FAB — 스크롤 시 라벨이 접히는 확장형 */}
      <Animated.View style={[s.fab]}>
        <Pressable style={s.fabInner}>
          <Text style={{ color: '#fff', fontSize: 20 }}>＋</Text>
          <Animated.View style={{ maxWidth: fabWidth.interpolate({ inputRange: [0, 1], outputRange: [0, 90] }),
                                  overflow: 'hidden' }}>
            <Text style={s.fabLabel} numberOfLines={1}>글쓰기</Text>
          </Animated.View>
        </Pressable>
      </Animated.View>
    </SafeAreaView>
  );
}

const s = StyleSheet.create({
  root: { flex: 1, backgroundColor: '#fff' },
  head: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center',
          paddingHorizontal: 18, paddingVertical: 10 },
  loc: { fontSize: 18, fontWeight: '900', color: T.ink },
  hIcon: { fontSize: 18 },
  chatBadge: { position: 'absolute', top: -5, right: -8, width: 16, height: 16, borderRadius: 8,
               backgroundColor: T.primary, alignItems: 'center', justifyContent: 'center' },
  chatBadgeText: { color: '#fff', fontSize: 9.5, fontWeight: '700' },
  chip: { borderWidth: 1, borderColor: T.chipBorder, borderRadius: 999,
          paddingHorizontal: 14, paddingVertical: 7 },
  chipOn: { backgroundColor: T.ink, borderColor: T.ink },
  chipText: { fontSize: 13, color: '#4D5159' },
  chipTextOn: { color: '#fff', fontWeight: '700' },
  cell: { flexDirection: 'row', gap: 14, padding: 16,
          borderBottomWidth: 1, borderBottomColor: T.divider },
  thumb: { width: T.thumbSize, height: T.thumbSize, borderRadius: T.radiusThumb,
           overflow: 'hidden', backgroundColor: T.divider,
           alignItems: 'center', justifyContent: 'center' },
  thumbImg: { ...StyleSheet.absoluteFillObject },
  thumbEmoji: { fontSize: 36, opacity: .35 },
  title: { fontSize: 15, color: T.ink, lineHeight: 21 },
  reserved: { backgroundColor: T.reserved, color: '#fff', fontSize: 11, fontWeight: '700',
              borderRadius: 5, overflow: 'hidden' },
  meta: { marginTop: 4, fontSize: 12.5, color: T.sub },
  price: { marginTop: 5, fontSize: 16, fontWeight: '900', color: T.ink },
  counts: { marginTop: 'auto', alignSelf: 'flex-end', fontSize: 12, color: T.sub },
  fab: { position: 'absolute', right: 18, bottom: 28 },
  fabInner: { flexDirection: 'row', alignItems: 'center', gap: 8, height: 54,
              paddingHorizontal: 18, borderRadius: 27, backgroundColor: T.primary,
              shadowColor: T.primary, shadowOpacity: .45, shadowRadius: 12,
              shadowOffset: { width: 0, height: 10 }, elevation: 8 },
  fabLabel: { color: '#fff', fontSize: 15, fontWeight: '700' },
});
