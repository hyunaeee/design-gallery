// Copyright (c) 2026 hyunaeee · MIT License — see /LICENSE at the project root.
/**
 * 주문/결제 — 원페이지 체크아웃 (React Native)
 * 의존성: react-native 코어만 사용 — Expo Snack에 그대로 붙여넣어 실행 가능
 * 토큰: exports/tokens/payment.tokens.json 과 1:1 대응
 * 동작: 결제수단 라디오 카드 → 쿠폰 바텀시트(할인 실시간 재계산) →
 *       전체 동의 일괄 토글 → 결제 스피너 1초 → 체크마크 완료 화면 → 확인 복귀
 */
import React, { useEffect, useRef, useState } from 'react';
import {
  SafeAreaView, ScrollView, View, Text, Pressable, Modal, Animated,
  ActivityIndicator, StyleSheet,
} from 'react-native';

/* ── 디자인 토큰 (payment.tokens.json) ── */
const T = {
  primary: '#1E45D6', tint: '#F0F4FF', bg: '#F4F5F9', surface: '#FFFFFF',
  ink: '#141C3D', sub: '#8A91A8', discount: '#F04452', border: '#E1E4EE', divider: '#EDEFF5',
  radiusCard: 18, radiusRadio: 14, radiusButton: 16, radiusSheet: 24, radiusThumb: 12,
  thumbSize: 56, checkboxSize: 21, spinnerMs: 1000,
};

const GOODS = 83900, SHIP = 3000;
const ITEMS = [
  { e: '🧴', bg: '#EEF4FF', name: '센텔라 수분 진정 크림 50ml', opt: '단품 · 1개', price: 24900 },
  { e: '👟', bg: '#F3F0FF', name: '데일리 러닝화 클라우드 화이트', opt: '270mm · 1개', price: 59000 },
];
const PAYS = [
  { id: 'card',  mk: '💳', label: '신용카드' },
  { id: 'naver', mk: 'N',  label: '네이버페이' },
  { id: 'kakao', mk: '💬', label: '카카오페이' },
  { id: 'toss',  mk: '💸', label: '토스페이' },
];
const COUPONS = [
  { id: 'none',  amt: '—',      name: '사용 안 함',        cond: '',                  disc: 0,    ship: SHIP },
  { id: 'c3000', amt: '3,000원', name: '신규가입 감사 쿠폰', cond: '2만원 이상 구매 시', disc: 3000, ship: SHIP },
  { id: 'c10p',  amt: '10%',    name: '여름 세일 쿠폰',     cond: '최대 8,000원 할인',  disc: Math.min(Math.round(GOODS * 0.1), 8000), ship: SHIP },
  { id: 'cship', amt: '배송비',  name: '무료배송 쿠폰',      cond: '배송비 3,000원 무료', disc: 0,   ship: 0 },
];
const TERMS = [
  { id: 't1', label: '[필수] 구매조건 확인 및 결제 진행 동의', req: true },
  { id: 't2', label: '[필수] 개인정보 제3자 제공 동의',        req: true },
  { id: 't3', label: '[선택] 마케팅 정보 수신 동의',           req: false },
];
const won = n => n.toLocaleString('ko-KR') + '원';

/* 원형 체크박스 */
function Check({ on }) {
  return (
    <View style={[s.cbBox, on && { backgroundColor: T.primary, borderColor: T.primary }]}>
      <Text style={{ color: '#FFF', fontSize: 11, lineHeight: 13 }}>✓</Text>
    </View>
  );
}

export default function PaymentFlow() {
  const [pay, setPay] = useState('card');
  const [coupon, setCoupon] = useState('none');
  const [sheet, setSheet] = useState(false);
  const [terms, setTerms] = useState({ t1: false, t2: false, t3: false });
  const [paying, setPaying] = useState(false);
  const [done, setDone] = useState(false);
  const [orderNo, setOrderNo] = useState('');
  const timer = useRef(null);
  const checkScale = useRef(new Animated.Value(0)).current;

  useEffect(() => () => clearTimeout(timer.current), []);

  const c = COUPONS.find(x => x.id === coupon);
  const total = GOODS + c.ship - c.disc;
  const allOn = TERMS.every(t => terms[t.id]);
  const reqOn = TERMS.filter(t => t.req).every(t => terms[t.id]);

  const toggleAll = () => {
    const next = !allOn;
    setTerms({ t1: next, t2: next, t3: next });
  };

  /* 결제: 스피너 1초 → 완료 화면 (체크 스프링 등장) */
  const doPay = () => {
    if (paying || !reqOn) return;
    setPaying(true);
    timer.current = setTimeout(() => {
      setOrderNo('ORD-20260710-' + String(Math.floor(1000 + Math.random() * 9000)));
      setDone(true);
      setPaying(false);
      checkScale.setValue(0);
      Animated.spring(checkScale, { toValue: 1, friction: 5, tension: 90, useNativeDriver: true }).start();
    }, T.spinnerMs);
  };

  /* ── 완료 화면 ── */
  if (done) {
    return (
      <SafeAreaView style={s.root}>
        <View style={s.doneWrap}>
          <Animated.View style={[s.doneCircle, { transform: [{ scale: checkScale }] }]}>
            <Text style={{ color: '#FFF', fontSize: 42, fontWeight: '900' }}>✓</Text>
          </Animated.View>
          <Text style={s.doneTitle}>결제가 완료됐어요</Text>
          <Text style={s.doneSub}>주문 내역은 마이페이지에서{'\n'}확인할 수 있어요</Text>
          <View style={s.ordNo}><Text style={{ color: T.primary, fontSize: 12.5 }}>{orderNo}</Text></View>
          <Text style={{ marginTop: 22, fontSize: 15, color: T.ink }}>
            결제 금액  <Text style={{ fontSize: 24, fontWeight: '900', color: T.primary }}>{won(total)}</Text>
          </Text>
        </View>
        <View style={{ padding: 26 }}>
          <Pressable style={({ pressed }) => [s.cta, pressed && { opacity: 0.85 }]} onPress={() => setDone(false)}>
            <Text style={s.ctaText}>확인</Text>
          </Pressable>
        </View>
      </SafeAreaView>
    );
  }

  /* ── 결제 화면 ── */
  return (
    <SafeAreaView style={s.root}>
      <View style={s.head}><Text style={s.headTitle}>주문/결제</Text></View>
      <ScrollView contentContainerStyle={{ padding: 16, paddingBottom: 120 }}>

        {/* 주문 상품 */}
        <View style={s.card}>
          <Text style={s.secTitle}>주문 상품 {ITEMS.length}건</Text>
          {ITEMS.map((it, i) => (
            <View key={it.name} style={[s.item, i < ITEMS.length - 1 && { borderBottomWidth: 1, borderBottomColor: T.divider }]}>
              <View style={[s.thumb, { backgroundColor: it.bg }]}><Text style={{ fontSize: 24 }}>{it.e}</Text></View>
              <View style={{ flex: 1 }}>
                <Text style={{ fontSize: 13.5, fontWeight: '500', color: T.ink }}>{it.name}</Text>
                <Text style={{ marginTop: 2, fontSize: 12, color: T.sub }}>{it.opt}</Text>
                <Text style={{ marginTop: 4, fontSize: 14.5, fontWeight: '800', color: T.ink }}>{won(it.price)}</Text>
              </View>
            </View>
          ))}
        </View>

        {/* 배송지 */}
        <View style={s.card}>
          <Text style={s.secTitle}>배송지</Text>
          <View style={{ flexDirection: 'row', gap: 10, marginTop: 8 }}>
            <View style={{ flex: 1 }}>
              <Text style={{ fontSize: 14, fontWeight: '700', color: T.ink }}>
                루나 <Text style={{ fontSize: 10.5, color: T.primary }}> 기본</Text>
              </Text>
              <Text style={{ marginTop: 4, fontSize: 12.5, color: T.sub, lineHeight: 19 }}>
                서울 성동구 왕십리로 83-21, 101동 1204호{'\n'}010-1234-5678
              </Text>
            </View>
            <Pressable style={s.chgBtn}><Text style={{ fontSize: 12, fontWeight: '700', color: T.ink }}>변경</Text></Pressable>
          </View>
        </View>

        {/* 결제수단 라디오 카드 (2열) */}
        <View style={s.card}>
          <Text style={s.secTitle}>결제 수단</Text>
          <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 9, marginTop: 12 }}>
            {PAYS.map(p => {
              const on = pay === p.id;
              return (
                <Pressable key={p.id} onPress={() => setPay(p.id)}
                           style={[s.payCard, on && { borderColor: T.primary, backgroundColor: T.tint, borderWidth: 2 }]}>
                  <Text style={{ fontSize: 16, fontWeight: p.id === 'naver' ? '900' : '400',
                                 color: p.id === 'naver' ? '#03C75A' : T.ink }}>{p.mk}</Text>
                  <Text style={{ fontSize: 13.5, color: T.ink, fontWeight: on ? '700' : '500' }}>{p.label}</Text>
                </Pressable>
              );
            })}
          </View>
          {/* 쿠폰 행 → 바텀시트 */}
          <Pressable style={s.couponRow} onPress={() => setSheet(true)}>
            <Text style={{ fontSize: 13.5, color: T.sub }}>쿠폰</Text>
            <Text style={{ fontSize: 13.5, fontWeight: '700', color: coupon === 'none' ? T.ink : T.primary }}>
              {c.name}  <Text style={{ color: '#C3C8D8' }}>›</Text>
            </Text>
          </Pressable>
        </View>

        {/* 약관 동의 — 전체 동의 일괄 토글 */}
        <View style={s.card}>
          <Pressable style={[s.cbRow, { borderBottomWidth: 1, borderBottomColor: T.divider, paddingBottom: 13 }]}
                     onPress={toggleAll}>
            <Check on={allOn} />
            <Text style={{ fontSize: 14.5, fontWeight: '700', color: T.ink }}>전체 동의</Text>
          </Pressable>
          {TERMS.map(t => (
            <Pressable key={t.id} style={s.cbRow} onPress={() => setTerms(x => ({ ...x, [t.id]: !x[t.id] }))}>
              <Check on={terms[t.id]} />
              <Text style={{ fontSize: 13, color: T.sub }}>{t.label}</Text>
            </Pressable>
          ))}
        </View>

        {/* 금액 요약 — 쿠폰 반영 실시간 재계산 */}
        <View style={s.card}>
          <Text style={s.secTitle}>결제 금액</Text>
          <View style={s.sumRow}><Text style={s.sumL}>상품 금액</Text><Text style={s.sumR}>{won(GOODS)}</Text></View>
          <View style={s.sumRow}><Text style={s.sumL}>배송비</Text><Text style={s.sumR}>{c.ship ? won(c.ship) : '무료'}</Text></View>
          <View style={s.sumRow}>
            <Text style={s.sumL}>쿠폰 할인</Text>
            <Text style={{ fontSize: 13.5, fontWeight: '700', color: T.discount }}>{c.disc ? '-' + won(c.disc) : '0원'}</Text>
          </View>
          <View style={[s.sumRow, s.sumTotal]}>
            <Text style={{ fontSize: 14.5, fontWeight: '700', color: T.ink }}>총 결제 금액</Text>
            <Text style={{ fontSize: 18, fontWeight: '900', color: T.primary }}>{won(total)}</Text>
          </View>
        </View>
      </ScrollView>

      {/* 하단 고정 결제 버튼 */}
      <View style={s.payBar}>
        <Pressable onPress={doPay} disabled={!reqOn}
                   style={({ pressed }) => [s.cta, !reqOn && { backgroundColor: '#C3C8D8' }, pressed && reqOn && { opacity: 0.85 }]}>
          {paying ? <ActivityIndicator color="#FFF" />
                  : <Text style={s.ctaText}>{won(total)} 결제하기</Text>}
        </Pressable>
      </View>

      {/* 쿠폰 바텀시트 */}
      <Modal visible={sheet} transparent animationType="slide" onRequestClose={() => setSheet(false)}>
        <Pressable style={s.dim} onPress={() => setSheet(false)} />
        <View style={s.sheet}>
          <View style={s.grab} />
          <Text style={{ fontSize: 17, fontWeight: '900', color: T.ink, marginBottom: 12 }}>쿠폰 선택</Text>
          {COUPONS.map(cp => {
            const on = coupon === cp.id;
            return (
              <Pressable key={cp.id} onPress={() => { setCoupon(cp.id); setSheet(false); }}
                         style={[s.cp, on && { borderColor: T.primary, backgroundColor: T.tint }]}>
                <Text style={{ minWidth: 62, fontSize: 16, fontWeight: '900', color: T.primary }}>{cp.amt}</Text>
                <View style={{ flex: 1 }}>
                  <Text style={{ fontSize: 13.5, fontWeight: '700', color: T.ink }}>{cp.name}</Text>
                  {!!cp.cond && <Text style={{ marginTop: 2, fontSize: 11.5, color: T.sub }}>{cp.cond}</Text>}
                </View>
              </Pressable>
            );
          })}
        </View>
      </Modal>
    </SafeAreaView>
  );
}

const s = StyleSheet.create({
  root: { flex: 1, backgroundColor: T.bg },
  head: { alignItems: 'center', paddingVertical: 12 },
  headTitle: { fontSize: 16.5, fontWeight: '700', color: T.ink },
  card: { backgroundColor: T.surface, borderRadius: T.radiusCard, padding: 18, marginBottom: 12 },
  secTitle: { fontSize: 15, fontWeight: '700', color: T.ink },
  item: { flexDirection: 'row', gap: 12, paddingVertical: 12 },
  thumb: { width: T.thumbSize, height: T.thumbSize, borderRadius: T.radiusThumb,
           alignItems: 'center', justifyContent: 'center' },
  chgBtn: { borderWidth: 1, borderColor: T.border, borderRadius: 10, paddingVertical: 7,
            paddingHorizontal: 12, alignSelf: 'flex-start' },
  payCard: { width: '48.4%', flexDirection: 'row', alignItems: 'center', gap: 8,
             borderWidth: 1.5, borderColor: T.border, borderRadius: T.radiusRadio,
             paddingVertical: 14, paddingHorizontal: 13, backgroundColor: '#FFF' },
  couponRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center',
               marginTop: 14, paddingTop: 4 },
  cbRow: { flexDirection: 'row', alignItems: 'center', gap: 10, paddingVertical: 9 },
  cbBox: { width: T.checkboxSize, height: T.checkboxSize, borderRadius: T.checkboxSize / 2,
           borderWidth: 1.5, borderColor: T.border, alignItems: 'center', justifyContent: 'center' },
  sumRow: { flexDirection: 'row', justifyContent: 'space-between', paddingVertical: 5.5 },
  sumL: { fontSize: 13.5, color: T.sub },
  sumR: { fontSize: 13.5, fontWeight: '500', color: T.ink },
  sumTotal: { borderTopWidth: 1, borderTopColor: T.divider, marginTop: 8, paddingTop: 13 },
  payBar: { position: 'absolute', bottom: 0, left: 0, right: 0, padding: 16, paddingBottom: 28,
            backgroundColor: T.bg },
  cta: { backgroundColor: T.primary, borderRadius: T.radiusButton, paddingVertical: 16,
         alignItems: 'center', justifyContent: 'center', minHeight: 54 },
  ctaText: { color: '#FFF', fontSize: 16, fontWeight: '700' },
  dim: { flex: 1, backgroundColor: 'rgba(20,28,61,.5)' },
  sheet: { backgroundColor: '#FFF', borderTopLeftRadius: T.radiusSheet, borderTopRightRadius: T.radiusSheet,
           paddingHorizontal: 20, paddingTop: 12, paddingBottom: 34 },
  grab: { width: 44, height: 5, borderRadius: 99, backgroundColor: T.divider, alignSelf: 'center', marginBottom: 16 },
  cp: { flexDirection: 'row', alignItems: 'center', gap: 12, borderWidth: 1.5, borderColor: T.border,
        borderRadius: T.radiusRadio, padding: 14, marginBottom: 9 },
  doneWrap: { flex: 1, alignItems: 'center', justifyContent: 'center', paddingHorizontal: 34 },
  doneCircle: { width: 96, height: 96, borderRadius: 48, backgroundColor: T.primary,
                alignItems: 'center', justifyContent: 'center' },
  doneTitle: { marginTop: 26, fontSize: 22, fontWeight: '900', color: T.ink },
  doneSub: { marginTop: 9, fontSize: 13.5, color: T.sub, lineHeight: 22, textAlign: 'center' },
  ordNo: { marginTop: 16, backgroundColor: T.tint, borderRadius: 10, paddingVertical: 8, paddingHorizontal: 14 },
});
