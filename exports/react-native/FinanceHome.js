// Copyright (c) 2026 hyunaeee · MIT License — see /LICENSE at the project root.
/**
 * 금융 홈 — 토스 스타일 (React Native)
 * 의존성: react-native 코어만 사용 — Expo Snack에 그대로 붙여넣어 실행 가능
 * 토큰: exports/tokens/finance.tokens.json 과 1:1 대응
 */
import React, { useState } from 'react';
import {
  SafeAreaView, ScrollView, View, Text, Pressable, Modal, StyleSheet,
} from 'react-native';

/* ── 디자인 토큰 (finance.tokens.json) ── */
const T = {
  primary: '#3182F6', bg: '#F2F4F6', surface: '#FFFFFF',
  ink: '#191F28', sub: '#8B95A1', negative: '#F04452', track: '#E5E8EB',
  radiusCard: 20, radiusButton: 14, radiusSheet: 28,
};

const ACCOUNTS = [
  { id: '1', icon: '🏦', iconBg: '#E8F3FF', name: '토스뱅크 통장', amount: 2483000 },
  { id: '2', icon: '🐷', iconBg: '#FFF3E0', name: '비상금 저금통', amount: 518200 },
  { id: '3', icon: '📈', iconBg: '#EEF4FF', name: '증권 계좌', amount: 7214850 },
];
const SPEND_WEEK = [
  { d: '월', h: 38 }, { d: '화', h: 62 }, { d: '수', h: 30 }, { d: '목', h: 88, hot: true },
  { d: '금', h: 46 }, { d: '토', h: 20 }, { d: '일', h: 12 },
];
const STOCKS = [
  { logo: 'A', logoBg: '#1A1A1A', name: '애플', price: '312,400원', delta: '+2.4%', up: true },
  { logo: 'N', logoBg: '#3182F6', name: '엔비디아', price: '198,750원', delta: '+5.1%', up: true },
  { logo: '네', logoBg: '#03C75A', name: '네이버', price: '224,000원', delta: '-0.8%', up: false },
];
const TABS = ['🏠 홈', '🎁 혜택', '💸 토스페이', '📊 증권', '☰ 전체'];
const won = n => n.toLocaleString('ko-KR') + '원';

export default function FinanceHome() {
  const [sheet, setSheet] = useState(null);   // 선택된 계좌 → 바텀시트
  const [tab, setTab] = useState(0);

  return (
    <SafeAreaView style={s.root}>
      {/* 헤더 */}
      <View style={s.head}>
        <Text style={s.brand}>toss</Text>
        <Text style={s.headIcons}>💬  🔔</Text>
      </View>

      <ScrollView contentContainerStyle={{ padding: 16, paddingBottom: 100 }}>
        {/* 자산 카드 */}
        <View style={s.card}>
          <View style={s.cardTitleRow}>
            <Text style={s.cardTitle}>자산</Text>
            <Text style={s.cardSub}>순서 편집</Text>
          </View>
          {ACCOUNTS.map(a => (
            <Pressable key={a.id} style={({ pressed }) => [s.acct, pressed && { backgroundColor: T.bg }]}
                       onPress={() => setSheet(a)}>
              <View style={[s.acctIcon, { backgroundColor: a.iconBg }]}><Text style={{ fontSize: 18 }}>{a.icon}</Text></View>
              <View style={{ flex: 1 }}>
                <Text style={s.acctName}>{a.name}</Text>
                <Text style={s.acctAmt}>{won(a.amount)}</Text>
              </View>
              <Text style={{ color: '#D1D6DB', fontSize: 16 }}>›</Text>
            </Pressable>
          ))}
          <Pressable style={({ pressed }) => [s.sendBtn, pressed && { opacity: .85 }]}>
            <Text style={s.sendBtnText}>송금하기</Text>
          </Pressable>
        </View>

        {/* 주간 소비 차트 */}
        <View style={s.card}>
          <View style={s.cardTitleRow}>
            <Text style={s.cardTitle}>이번 주 소비</Text>
            <Text style={s.cardSub}>7월 6일 ~ 오늘</Text>
          </View>
          <View style={{ flexDirection: 'row', alignItems: 'baseline', gap: 8, marginTop: 6 }}>
            <Text style={s.spendTotal}>184,300원</Text>
            <Text style={{ color: T.negative, fontSize: 12.5, fontWeight: '700' }}>지난주보다 12% ↓</Text>
          </View>
          <View style={s.bars}>
            {SPEND_WEEK.map(b => (
              <View key={b.d} style={{ flex: 1, alignItems: 'center', gap: 6 }}>
                <View style={{ height: 74, width: '100%', justifyContent: 'flex-end' }}>
                  <View style={{ height: `${b.h}%`, borderRadius: 7,
                                 backgroundColor: b.hot ? T.primary : T.track }} />
                </View>
                <Text style={{ fontSize: 10.5, color: T.sub }}>{b.d}</Text>
              </View>
            ))}
          </View>
        </View>

        {/* 주식 리스트 */}
        <View style={s.card}>
          <View style={s.cardTitleRow}>
            <Text style={s.cardTitle}>내 주식</Text><Text style={s.cardSub}>실시간</Text>
          </View>
          {STOCKS.map(st => (
            <View key={st.name} style={s.stock}>
              <View style={[s.stockLogo, { backgroundColor: st.logoBg }]}>
                <Text style={{ color: '#fff', fontWeight: '800', fontSize: 14 }}>{st.logo}</Text>
              </View>
              <Text style={s.stockName}>{st.name}</Text>
              <View style={{ alignItems: 'flex-end' }}>
                <Text style={{ fontSize: 14.5, fontWeight: '700', color: T.ink }}>{st.price}</Text>
                <Text style={{ fontSize: 12, fontWeight: '700',
                               color: st.up ? T.negative : T.primary }}>{st.delta}</Text>
              </View>
            </View>
          ))}
        </View>
      </ScrollView>

      {/* 탭바 */}
      <View style={s.tabbar}>
        {TABS.map((t, i) => (
          <Pressable key={t} style={s.tab} onPress={() => setTab(i)}>
            <Text style={{ fontSize: 19, opacity: tab === i ? 1 : .4 }}>{t.split(' ')[0]}</Text>
            <Text style={[s.tabLabel, tab === i && { color: T.ink, fontWeight: '700' }]}>{t.split(' ')[1]}</Text>
          </Pressable>
        ))}
      </View>

      {/* 바텀시트 — Modal(slide) */}
      <Modal visible={!!sheet} transparent animationType="slide" onRequestClose={() => setSheet(null)}>
        <Pressable style={s.dim} onPress={() => setSheet(null)} />
        <View style={s.sheet}>
          <View style={s.grab} />
          <Text style={s.sheetTitle}>{sheet?.name}</Text>
          <Text style={s.sheetBal}>잔액 {sheet ? won(sheet.amount) : ''}</Text>
          <View style={{ flexDirection: 'row', gap: 10, marginTop: 20 }}>
            <Pressable style={[s.sheetBtn, { backgroundColor: T.bg }]} onPress={() => setSheet(null)}>
              <Text style={{ fontWeight: '700', color: T.ink }}>내역 보기</Text>
            </Pressable>
            <Pressable style={[s.sheetBtn, { backgroundColor: T.primary }]} onPress={() => setSheet(null)}>
              <Text style={{ fontWeight: '700', color: '#fff' }}>송금</Text>
            </Pressable>
          </View>
        </View>
      </Modal>
    </SafeAreaView>
  );
}

const s = StyleSheet.create({
  root: { flex: 1, backgroundColor: T.bg },
  head: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center',
          paddingHorizontal: 20, paddingVertical: 10 },
  brand: { fontSize: 21, fontWeight: '900', color: T.primary, letterSpacing: -0.5 },
  headIcons: { fontSize: 16, color: T.sub },
  card: { backgroundColor: T.surface, borderRadius: T.radiusCard, padding: 20, marginBottom: 14 },
  cardTitleRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  cardTitle: { fontSize: 15, fontWeight: '700', color: T.ink },
  cardSub: { fontSize: 12.5, color: T.sub },
  acct: { flexDirection: 'row', alignItems: 'center', gap: 12, paddingVertical: 13,
          paddingHorizontal: 4, borderRadius: 14 },
  acctIcon: { width: 40, height: 40, borderRadius: 14, alignItems: 'center', justifyContent: 'center' },
  acctName: { fontSize: 13, color: T.sub },
  acctAmt: { fontSize: 16.5, fontWeight: '700', color: T.ink },
  sendBtn: { marginTop: 10, backgroundColor: T.primary, borderRadius: T.radiusButton,
             paddingVertical: 14, alignItems: 'center' },
  sendBtnText: { color: '#fff', fontSize: 15, fontWeight: '700' },
  spendTotal: { fontSize: 24, fontWeight: '900', color: T.ink },
  bars: { flexDirection: 'row', gap: 8, marginTop: 16 },
  stock: { flexDirection: 'row', alignItems: 'center', gap: 12, paddingVertical: 11 },
  stockLogo: { width: 36, height: 36, borderRadius: 18, alignItems: 'center', justifyContent: 'center' },
  stockName: { flex: 1, fontSize: 14.5, color: T.ink },
  tabbar: { position: 'absolute', bottom: 0, left: 0, right: 0, flexDirection: 'row',
            backgroundColor: '#FFFFFFF2', borderTopWidth: 1, borderTopColor: '#EEF0F3',
            paddingTop: 8, paddingBottom: 24 },
  tab: { flex: 1, alignItems: 'center', gap: 3 },
  tabLabel: { fontSize: 10.5, color: '#B0B8C1' },
  dim: { flex: 1, backgroundColor: 'rgba(25,31,40,.5)' },
  sheet: { backgroundColor: '#fff', borderTopLeftRadius: T.radiusSheet, borderTopRightRadius: T.radiusSheet,
           paddingHorizontal: 22, paddingTop: 12, paddingBottom: 34 },
  grab: { width: 44, height: 5, borderRadius: 99, backgroundColor: T.track, alignSelf: 'center', marginBottom: 18 },
  sheetTitle: { fontSize: 18, fontWeight: '900', color: T.ink },
  sheetBal: { marginTop: 6, fontSize: 13.5, color: T.sub },
  sheetBtn: { flex: 1, paddingVertical: 15, borderRadius: T.radiusButton, alignItems: 'center' },
});
