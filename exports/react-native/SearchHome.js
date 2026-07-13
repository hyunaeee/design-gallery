// Copyright (c) 2026 hyunaeee · MIT License — see /LICENSE at the project root.
/**
 * 검색 — 자동완성 & 스켈레톤 (React Native)
 * 의존성: react-native 코어만 사용 — Expo Snack에 그대로 붙여넣어 실행 가능
 * 토큰: exports/tokens/search.tokens.json 과 1:1 대응
 * 동작: 타이핑 → 자동완성 실시간 필터(매칭 하이라이트) → 검색 →
 *       스켈레톤 셔머 0.8초 → 결과 카드 리스트 → 뒤로가기 복귀
 */
import React, { useEffect, useRef, useState } from 'react';
import {
  SafeAreaView, ScrollView, View, Text, TextInput, Pressable, Animated, StyleSheet,
} from 'react-native';

/* ── 디자인 토큰 (search.tokens.json) ── */
const T = {
  primary: '#00C471', bg: '#FFFFFF', field: '#F4F6F8',
  ink: '#191F28', sub: '#8B95A1', up: '#F04452', down: '#3182F6',
  skeleton: '#EEF1F4', divider: '#F2F4F6',
  radiusBar: 12, radiusThumb: 14, barHeight: 48, thumbSize: 84, skeletonMs: 800,
};

const KEYWORDS = ['나이키 운동화', '나이키 바람막이', '니트 조끼', '니트 원피스', '노트북 파우치',
  '노트북 거치대', '무선 이어폰', '무선 키보드', '캠핑 의자', '캠핑 테이블', '여름 원피스',
  '후드집업', '크로스백', '물티슈', '핸드폰 케이스', '제습기', '미니 선풍기', '샤워 필터'];
const POPULAR = [
  { kw: '제습기', d: 'up', n: 2 },        { kw: '미니 선풍기', d: 'same' },
  { kw: '나이키 운동화', d: 'up', n: 1 },  { kw: '캠핑 의자', d: 'down', n: 2 },
  { kw: '무선 이어폰', d: 'up', n: 3 },    { kw: '여름 원피스', d: 'same' },
  { kw: '물티슈', d: 'down', n: 1 },       { kw: '크로스백', d: 'up', n: 4 },
  { kw: '후드집업', d: 'down', n: 3 },     { kw: '노트북 거치대', d: 'new' },
];
const RESULT_TPL = [
  { e: '⭐', bg: '#E8F9F1', brand: '그린마켓',   sfx: '베스트 셀러',     price: '29,800', sale: '32%', rate: '4.8 (1,204)' },
  { e: '🛍️', bg: '#FFF3E6', brand: '데일리굿즈', sfx: '인기 상품',       price: '18,900', sale: '15%', rate: '4.6 (891)' },
  { e: '📦', bg: '#EEF4FF', brand: '모던하우스', sfx: '프리미엄 에디션', price: '45,000', sale: '',    rate: '4.9 (2,033)' },
  { e: '🎁', bg: '#FDEEF2', brand: '어반스토어', sfx: '가성비 추천',     price: '12,500', sale: '40%', rate: '4.5 (367)' },
  { e: '🧺', bg: '#F3F0FF', brand: '리빙플러스', sfx: '신상품',          price: '23,400', sale: '',    rate: '4.7 (128)' },
];

/* 매칭 부분 하이라이트 — query 기준 split 후 매칭 구간만 그린 볼드 */
function Highlight({ text, query }) {
  const parts = text.split(query);
  return (
    <Text style={s.autoText}>
      {parts.map((p, i) => (
        <Text key={i}>
          {p}{i < parts.length - 1 && <Text style={{ color: T.primary, fontWeight: '700' }}>{query}</Text>}
        </Text>
      ))}
    </Text>
  );
}

/* 스켈레톤 블록 — opacity 펄스 셔머 */
function Skeleton({ style }) {
  const pulse = useRef(new Animated.Value(0.55)).current;
  useEffect(() => {
    const loop = Animated.loop(Animated.sequence([
      Animated.timing(pulse, { toValue: 1, duration: 550, useNativeDriver: true }),
      Animated.timing(pulse, { toValue: 0.55, duration: 550, useNativeDriver: true }),
    ]));
    loop.start();
    return () => loop.stop();
  }, [pulse]);
  return <Animated.View style={[{ backgroundColor: T.skeleton, borderRadius: 8, opacity: pulse }, style]} />;
}

export default function SearchHome() {
  const [query, setQuery] = useState('');
  const [focused, setFocused] = useState(false);
  const [phase, setPhase] = useState('home');     // 'home' | 'loading' | 'results'
  const [recents, setRecents] = useState(['무선 이어폰', '캠핑 의자', '니트 조끼']);
  const [searched, setSearched] = useState('');
  const timer = useRef(null);

  useEffect(() => () => clearTimeout(timer.current), []);

  const suggestions = query.trim() ? KEYWORDS.filter(k => k.includes(query.trim())) : [];

  /* 검색 실행: 최근 검색어 반영 → 스켈레톤 0.8초 → 결과 */
  const doSearch = kw => {
    const q = kw.trim();
    if (!q) return;
    setRecents(r => [q, ...r.filter(x => x !== q)].slice(0, 8));
    setSearched(q);
    setPhase('loading');
    clearTimeout(timer.current);
    timer.current = setTimeout(() => setPhase('results'), T.skeletonMs);
  };
  const goHome = () => { setPhase('home'); setQuery(''); setFocused(false); };

  /* ── 결과 화면 (스켈레톤 → 카드) ── */
  if (phase !== 'home') {
    return (
      <SafeAreaView style={s.root}>
        <View style={s.resHead}>
          <Pressable onPress={goHome} hitSlop={10}><Text style={s.back}>‹</Text></Pressable>
          <Text style={s.resQ} numberOfLines={1}>{searched}</Text>
          <Text style={{ fontSize: 17, opacity: 0.5 }}>🛒</Text>
        </View>
        <View style={s.resMeta}>
          <Text style={{ fontSize: 12.5, color: T.sub }}>
            검색 결과 <Text style={{ color: T.ink, fontWeight: '700' }}>{18 + (searched.length * 3) % 40}</Text>개
          </Text>
          <Text style={{ fontSize: 12.5, color: T.sub }}>추천순 ▾</Text>
        </View>
        <ScrollView>
          {phase === 'loading'
            ? [0, 1, 2, 3].map(i => (
                <View key={i} style={s.card}>
                  <Skeleton style={{ width: T.thumbSize, height: T.thumbSize, borderRadius: T.radiusThumb }} />
                  <View style={{ flex: 1, paddingTop: 6, gap: 9 }}>
                    <Skeleton style={{ height: 13, width: '38%' }} />
                    <Skeleton style={{ height: 13, width: '86%' }} />
                    <Skeleton style={{ height: 13, width: '52%' }} />
                  </View>
                </View>
              ))
            : RESULT_TPL.map(r => (
                <Pressable key={r.brand} style={({ pressed }) => [s.card, pressed && { backgroundColor: '#FAFBFC' }]}>
                  <View style={[s.thumb, { backgroundColor: r.bg }]}><Text style={{ fontSize: 32 }}>{r.e}</Text></View>
                  <View style={{ flex: 1, paddingTop: 3 }}>
                    <Text style={{ fontSize: 11.5, color: T.sub }}>{r.brand}</Text>
                    <Text style={s.cardName} numberOfLines={2}>{searched} {r.sfx}</Text>
                    <Text style={s.cardPrice}>
                      {!!r.sale && <Text style={{ color: T.primary }}>{r.sale} </Text>}{r.price}원
                    </Text>
                    <Text style={{ marginTop: 3, fontSize: 12, color: T.sub }}>★ {r.rate}</Text>
                  </View>
                </Pressable>
              ))}
        </ScrollView>
      </SafeAreaView>
    );
  }

  /* ── 검색 홈 ── */
  return (
    <SafeAreaView style={s.root}>
      {/* 검색바 — 포커스 시 취소 버튼 등장 */}
      <View style={s.searchHead}>
        <View style={[s.sbar, focused && { borderColor: T.primary, backgroundColor: '#FFF' }]}>
          <Text style={{ fontSize: 15, opacity: 0.55 }}>🔍</Text>
          <TextInput
            style={s.input} value={query} onChangeText={setQuery}
            placeholder="어떤 상품을 찾으세요?" placeholderTextColor="#B0B8C1"
            onFocus={() => setFocused(true)} returnKeyType="search"
            onSubmitEditing={() => doSearch(query)}
          />
          {!!query && (
            <Pressable style={s.clearDot} onPress={() => setQuery('')} hitSlop={8}>
              <Text style={{ color: '#FFF', fontSize: 10, lineHeight: 12 }}>✕</Text>
            </Pressable>
          )}
        </View>
        {focused && (
          <Pressable onPress={() => { setQuery(''); setFocused(false); }} hitSlop={8}>
            <Text style={s.cancel}>취소</Text>
          </Pressable>
        )}
      </View>

      {query.trim() ? (
        /* 자동완성 — 실시간 필터 + 매칭 하이라이트 */
        <ScrollView keyboardShouldPersistTaps="handled">
          {suggestions.length ? suggestions.map(k => (
            <Pressable key={k} onPress={() => doSearch(k)}
                       style={({ pressed }) => [s.autoItem, pressed && { backgroundColor: T.field }]}>
              <Text style={{ fontSize: 13, opacity: 0.45 }}>🔍</Text>
              <Highlight text={k} query={query.trim()} />
            </Pressable>
          )) : (
            <Text style={s.autoNone}>‘{query.trim()}’ 에 대한 추천 검색어가 없어요</Text>
          )}
        </ScrollView>
      ) : (
        <ScrollView contentContainerStyle={{ paddingHorizontal: 20, paddingBottom: 40 }}>
          {/* 최근 검색어 — 개별 X / 전체 삭제 */}
          <View style={s.secTitleRow}>
            <Text style={s.secTitle}>최근 검색어</Text>
            <Pressable onPress={() => setRecents([])}><Text style={s.secBtn}>전체 삭제</Text></Pressable>
          </View>
          <View style={s.chips}>
            {recents.length ? recents.map(r => (
              <Pressable key={r} style={s.chip} onPress={() => doSearch(r)}>
                <Text style={{ fontSize: 13, color: T.ink }}>{r}</Text>
                <Pressable hitSlop={8} onPress={() => setRecents(x => x.filter(v => v !== r))}>
                  <Text style={{ color: '#B0B8C1', fontSize: 12 }}>✕</Text>
                </Pressable>
              </Pressable>
            )) : <Text style={{ fontSize: 13, color: '#B0B8C1' }}>최근 검색어가 없어요</Text>}
          </View>

          {/* 인기 검색어 TOP 10 — 2열, 순위 등락 ▲▼ */}
          <View style={[s.secTitleRow, { marginTop: 26 }]}>
            <Text style={s.secTitle}>인기 검색어 TOP 10</Text>
            <Text style={s.secBtn}>오후 3시 기준</Text>
          </View>
          <View style={{ flexDirection: 'row', flexWrap: 'wrap' }}>
            {POPULAR.map((p, i) => (
              <Pressable key={p.kw} onPress={() => doSearch(p.kw)}
                         style={[s.pop, { width: '50%', paddingRight: i % 2 === 0 ? 12 : 0, paddingLeft: i % 2 ? 12 : 0 }]}>
                <Text style={[s.rank, i < 3 && { color: T.primary }]}>{i + 1}</Text>
                <Text style={{ flex: 1, fontSize: 14, color: T.ink }} numberOfLines={1}>{p.kw}</Text>
                <Text style={[s.delta, { color: p.d === 'up' ? T.up : p.d === 'down' ? T.down : p.d === 'new' ? T.primary : '#C4CAD1' }]}>
                  {p.d === 'up' ? `▲${p.n}` : p.d === 'down' ? `▼${p.n}` : p.d === 'new' ? 'NEW' : '—'}
                </Text>
              </Pressable>
            ))}
          </View>
        </ScrollView>
      )}
    </SafeAreaView>
  );
}

const s = StyleSheet.create({
  root: { flex: 1, backgroundColor: T.bg },
  searchHead: { flexDirection: 'row', alignItems: 'center', gap: 10, paddingHorizontal: 20, paddingVertical: 10 },
  sbar: { flex: 1, flexDirection: 'row', alignItems: 'center', gap: 8, height: T.barHeight,
          paddingHorizontal: 14, backgroundColor: T.field, borderRadius: T.radiusBar,
          borderWidth: 1.5, borderColor: 'transparent' },
  input: { flex: 1, fontSize: 16, color: T.ink, padding: 0 },
  clearDot: { width: 18, height: 18, borderRadius: 9, backgroundColor: '#D6DBE0',
              alignItems: 'center', justifyContent: 'center' },
  cancel: { fontSize: 14.5, color: T.ink },
  secTitleRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center',
                 marginTop: 14, marginBottom: 12 },
  secTitle: { fontSize: 15, fontWeight: '700', color: T.ink },
  secBtn: { fontSize: 12.5, color: T.sub },
  chips: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  chip: { flexDirection: 'row', alignItems: 'center', gap: 7, backgroundColor: T.field,
          borderRadius: 99, paddingVertical: 8, paddingHorizontal: 13 },
  pop: { flexDirection: 'row', alignItems: 'center', gap: 10, paddingVertical: 10,
         borderBottomWidth: 1, borderBottomColor: T.divider },
  rank: { width: 20, fontSize: 15, fontWeight: '800', color: T.sub },
  delta: { fontSize: 11, fontWeight: '700' },
  autoItem: { flexDirection: 'row', alignItems: 'center', gap: 11, paddingVertical: 13,
              paddingHorizontal: 20, borderRadius: 12 },
  autoText: { fontSize: 15, color: T.ink },
  autoNone: { padding: 26, fontSize: 13.5, color: T.sub, textAlign: 'center' },
  resHead: { flexDirection: 'row', alignItems: 'center', gap: 6, paddingHorizontal: 12,
             paddingVertical: 8, borderBottomWidth: 1, borderBottomColor: T.divider },
  back: { fontSize: 26, color: T.ink, paddingHorizontal: 8, lineHeight: 28 },
  resQ: { flex: 1, fontSize: 17, fontWeight: '700', color: T.ink },
  resMeta: { flexDirection: 'row', justifyContent: 'space-between', paddingHorizontal: 20, paddingVertical: 12 },
  card: { flexDirection: 'row', gap: 14, paddingHorizontal: 20, paddingVertical: 14 },
  thumb: { width: T.thumbSize, height: T.thumbSize, borderRadius: T.radiusThumb,
           alignItems: 'center', justifyContent: 'center' },
  cardName: { marginTop: 2, fontSize: 14, fontWeight: '500', color: T.ink, lineHeight: 20 },
  cardPrice: { marginTop: 5, fontSize: 16, fontWeight: '800', color: T.ink },
});
