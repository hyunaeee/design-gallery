// Copyright (c) 2026 hyunaeee · MIT License — see /LICENSE at the project root.
/**
 * 온보딩 → 로그인 플로우 (React Native)
 * 의존성: react-native 코어만 사용 — Expo Snack에 그대로 붙여넣어 실행 가능
 * 실제 동작: FlatList 페이징 온보딩 → dots 동기화 → 마지막 장에서 로그인 화면 전환
 * 토큰: exports/tokens/onboarding.tokens.json 과 1:1 대응
 */
import React, { useRef, useState } from 'react';
import {
  SafeAreaView, FlatList, View, Text, Pressable,
  useWindowDimensions, StyleSheet,
} from 'react-native';

/* ── 디자인 토큰 (onboarding.tokens.json) ── */
const T = {
  primary: '#6C5CE7', ink: '#1D1B2E', sub: '#8C88A3', dotOff: '#E3E0F0',
  kakao: '#FEE500', naver: '#03C75A', apple: '#111111', email: '#F2F2F7',
  lastLogin: '#FF4757',
};

const SLIDES = [
  { emoji: '🗂️', bg: '#ECE9FB', title: '흩어진 디자인 레퍼런스,\n한 곳에 모아요',
    body: '웹과 앱, 패턴과 컴포넌트별로 정리된\n레퍼런스를 검색 한 번으로 찾으세요.' },
  { emoji: '⚡', bg: '#E0F7F5', title: '보기만 하지 말고\n바로 코드로 쓰세요',
    body: '모든 레퍼런스는 동작하는 코드와 함께.\n복사해서 프로젝트에 붙여넣으면 끝.' },
  { emoji: '🤝', bg: '#FFF2E0', title: '팀과 함께 쓰면\n더 강력해져요',
    body: '컬렉션을 만들어 공유하고\n우리 팀의 디자인 언어를 만들어 가세요.' },
];

const SOCIALS = [
  { key: 'kakao', label: '💬 카카오로 계속하기', bg: T.kakao, fg: '#191600', last: true },
  { key: 'naver', label: 'N 네이버로 계속하기', bg: T.naver, fg: '#fff' },
  { key: 'apple', label: ' Apple로 계속하기', bg: T.apple, fg: '#fff' },
  { key: 'email', label: '✉️ 이메일로 계속하기', bg: T.email, fg: T.ink },
];

export default function Onboarding({ onDone }) {
  const { width } = useWindowDimensions();
  const [idx, setIdx] = useState(0);
  const [screen, setScreen] = useState('ob');   // 'ob' | 'login'
  const listRef = useRef(null);

  const next = () => {
    if (idx < SLIDES.length - 1)
      listRef.current?.scrollToIndex({ index: idx + 1, animated: true });
    else setScreen('login');
  };

  /* ── 로그인 화면 ── */
  if (screen === 'login') return (
    <SafeAreaView style={s.root}>
      <Pressable style={s.back} onPress={() => setScreen('ob')}>
        <Text style={{ fontSize: 20, color: T.sub }}>‹</Text>
      </Pressable>
      <View style={s.loginHero}>
        <View style={s.mark}><Text style={{ fontSize: 36, color: '#fff' }}>◈</Text></View>
        <Text style={s.loginTitle}>디자인 갤러리 시작하기</Text>
        <Text style={s.loginSub}>3초 만에 가입하고 모든 레퍼런스를 저장하세요</Text>
      </View>
      <View style={s.socials}>
        {SOCIALS.map(so => (
          <Pressable key={so.key} onPress={() => onDone?.(so.key)}
            style={({ pressed }) => [s.soc, { backgroundColor: so.bg }, pressed && { opacity: .85 }]}>
            <Text style={{ color: so.fg, fontSize: 15, fontWeight: '700' }}>{so.label}</Text>
            {so.last && <View style={s.lastBadge}><Text style={s.lastBadgeText}>마지막 로그인</Text></View>}
          </Pressable>
        ))}
      </View>
      <Text style={s.loginFoot}>
        이미 계정이 있나요? <Text style={{ color: T.primary, fontWeight: '700' }}>로그인</Text>
      </Text>
    </SafeAreaView>
  );

  /* ── 온보딩 캐러셀 ── */
  return (
    <SafeAreaView style={s.root}>
      <Pressable style={s.skip} onPress={() => setScreen('login')}>
        <Text style={{ color: T.sub, fontSize: 13.5 }}>건너뛰기</Text>
      </Pressable>

      <FlatList
        ref={listRef} data={SLIDES} horizontal pagingEnabled
        showsHorizontalScrollIndicator={false}
        keyExtractor={sl => sl.title}
        onMomentumScrollEnd={e => setIdx(Math.round(e.nativeEvent.contentOffset.x / width))}
        renderItem={({ item }) => (
          <View style={[s.slide, { width }]}>
            <View style={[s.art, { backgroundColor: item.bg }]}>
              <Text style={{ fontSize: 80 }}>{item.emoji}</Text>
            </View>
            <Text style={s.obTitle}>{item.title}</Text>
            <Text style={s.obBody}>{item.body}</Text>
          </View>
        )}
      />

      <View style={s.foot}>
        <View style={s.dots}>
          {SLIDES.map((_, i) => (
            <View key={i} style={[s.dot, idx === i && s.dotOn]} />
          ))}
        </View>
        <Pressable style={({ pressed }) => [s.cta, pressed && { opacity: .88 }]} onPress={next}>
          <Text style={s.ctaText}>{idx === SLIDES.length - 1 ? '시작하기' : '다음'}</Text>
        </Pressable>
      </View>
    </SafeAreaView>
  );
}

const s = StyleSheet.create({
  root: { flex: 1, backgroundColor: '#fff' },
  skip: { position: 'absolute', top: 56, right: 22, zIndex: 10 },
  slide: { alignItems: 'center', justifyContent: 'center', paddingHorizontal: 34, paddingTop: 40 },
  art: { width: 220, height: 220, borderRadius: 64, alignItems: 'center', justifyContent: 'center',
         marginBottom: 44 },
  obTitle: { fontSize: 25, fontWeight: '900', color: T.ink, textAlign: 'center', lineHeight: 34,
             letterSpacing: -0.5 },
  obBody: { marginTop: 13, fontSize: 14.5, color: T.sub, textAlign: 'center', lineHeight: 25 },
  foot: { paddingHorizontal: 26, paddingBottom: 42 },
  dots: { flexDirection: 'row', justifyContent: 'center', gap: 7, marginBottom: 20 },
  dot: { width: 7, height: 7, borderRadius: 4, backgroundColor: T.dotOff },
  dotOn: { width: 22, backgroundColor: T.primary },
  cta: { backgroundColor: T.primary, borderRadius: 16, paddingVertical: 16, alignItems: 'center' },
  ctaText: { color: '#fff', fontSize: 16, fontWeight: '700' },
  back: { position: 'absolute', top: 56, left: 22, zIndex: 10 },
  loginHero: { alignItems: 'center', paddingTop: 96 },
  mark: { width: 76, height: 76, borderRadius: 26, backgroundColor: T.primary,
          alignItems: 'center', justifyContent: 'center',
          shadowColor: T.primary, shadowOpacity: .5, shadowRadius: 16,
          shadowOffset: { width: 0, height: 12 }, elevation: 10 },
  loginTitle: { marginTop: 24, fontSize: 24, fontWeight: '900', color: T.ink },
  loginSub: { marginTop: 8, fontSize: 13.5, color: T.sub },
  socials: { paddingHorizontal: 26, paddingTop: 40, gap: 11 },
  soc: { height: 52, borderRadius: 14, alignItems: 'center', justifyContent: 'center' },
  lastBadge: { position: 'absolute', right: 14, top: -9, backgroundColor: T.lastLogin,
               borderRadius: 99, borderBottomLeftRadius: 3, paddingHorizontal: 9, paddingVertical: 3 },
  lastBadgeText: { color: '#fff', fontSize: 10, fontWeight: '700' },
  loginFoot: { position: 'absolute', bottom: 44, alignSelf: 'center', fontSize: 12.5, color: T.sub },
});
