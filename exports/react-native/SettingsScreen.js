// Copyright (c) 2026 hyunaeee · MIT License — see /LICENSE at the project root.
/**
 * 프로필/설정 — 다크 모드 전환 (React Native)
 * 의존성: react-native 코어만 사용 — Expo Snack에 그대로 붙여넣어 실행 가능
 * 토큰: exports/tokens/settings.tokens.json 과 1:1 대응
 * 동작: 다크 모드 스위치 → Animated 색상 보간으로 화면 전체가 부드럽게 다크 전환(350ms),
 *       알림 스위치 토글, 로그아웃 확인 다이얼로그(취소/로그아웃) + 토스트
 */
import React, { useMemo, useRef, useState } from 'react';
import {
  SafeAreaView, ScrollView, View, Text, Pressable, Switch, Modal, Animated, StyleSheet,
} from 'react-native';

/* ── 디자인 토큰 (settings.tokens.json) ── */
const T = {
  accent: '#FA4E6E', switchOn: '#34C759', danger: '#FF3B30', avatarEnd: '#FF9500',
  light: { bg: '#F2F2F7', card: '#FFFFFF', ink: '#1C1C1E', sub: '#8E8E93', line: '#E5E5EA' },
  dark:  { bg: '#0B0B0F', card: '#1C1C1E', ink: '#F2F2F7', sub: '#98989F', line: '#2C2C2E' },
  radiusProfile: 16, radiusGroup: 14, radiusIcon: 8, radiusDialog: 16,
  switchW: 51, avatar: 62, iconTile: 30, dialogW: 272, themeMs: 350,
};

export default function SettingsScreen() {
  const [dark, setDark] = useState(false);
  const [push, setPush] = useState(true);
  const [marketing, setMarketing] = useState(false);
  const [night, setNight] = useState(true);
  const [dlg, setDlg] = useState(false);
  const [toastMsg, setToastMsg] = useState('');
  const [cache, setCache] = useState('128MB');
  const anim = useRef(new Animated.Value(0)).current;      // 0 = 라이트, 1 = 다크
  const toastTimer = useRef(null);

  /* 다크 모드: Animated 색상 보간 → 화면 전체가 부드럽게 전환 */
  const toggleDark = v => {
    setDark(v);
    Animated.timing(anim, { toValue: v ? 1 : 0, duration: T.themeMs, useNativeDriver: false }).start();
  };
  const col = useMemo(() => {
    const mk = k => anim.interpolate({ inputRange: [0, 1], outputRange: [T.light[k], T.dark[k]] });
    return { bg: mk('bg'), card: mk('card'), ink: mk('ink'), sub: mk('sub'), line: mk('line') };
  }, [anim]);

  const toast = msg => {
    setToastMsg(msg);
    clearTimeout(toastTimer.current);
    toastTimer.current = setTimeout(() => setToastMsg(''), 1800);
  };

  /* 그룹 리스트 행 */
  const Row = ({ icon, iconBg, label, value, danger, onPress, isSwitch, swValue, onSwitch, first }) => (
    <Pressable onPress={onPress} disabled={!onPress && !isSwitch}>
      <Animated.View style={[s.row, !first && { borderTopWidth: StyleSheet.hairlineWidth, borderTopColor: col.line }]}>
        <View style={[s.icTile, { backgroundColor: iconBg }]}><Text style={{ fontSize: 14 }}>{icon}</Text></View>
        <Animated.Text style={[s.rowLabel, { color: danger ? T.danger : col.ink }, danger && { fontWeight: '500' }]}>
          {label}
        </Animated.Text>
        {!!value && <Animated.Text style={[s.rowValue, { color: col.sub }]}>{value}</Animated.Text>}
        {isSwitch
          ? <Switch value={swValue} onValueChange={onSwitch}
                    trackColor={{ false: T.light.line, true: T.switchOn }} thumbColor="#FFF" />
          : onPress || value ? <Text style={s.chev}>›</Text> : null}
      </Animated.View>
    </Pressable>
  );
  const Group = ({ label, children }) => (
    <>
      <Animated.Text style={[s.groupLabel, { color: col.sub }]}>{label}</Animated.Text>
      <Animated.View style={[s.group, { backgroundColor: col.card }]}>{children}</Animated.View>
    </>
  );

  return (
    <Animated.View style={{ flex: 1, backgroundColor: col.bg }}>
      <SafeAreaView style={{ flex: 1 }}>
        <Animated.Text style={[s.navTitle, { color: col.ink }]}>설정</Animated.Text>
        <ScrollView contentContainerStyle={{ paddingHorizontal: 16, paddingBottom: 50 }}>

          {/* 프로필 헤더 */}
          <Animated.View style={[s.profile, { backgroundColor: col.card }]}>
            <View style={s.avatar}><Text style={{ fontSize: 26 }}>🍒</Text></View>
            <View style={{ flex: 1 }}>
              <Animated.Text style={[s.profileName, { color: col.ink }]}>루나</Animated.Text>
              <Animated.Text style={[s.profileEmail, { color: col.sub }]}>luna@example.com</Animated.Text>
            </View>
            <Pressable onPress={() => toast('프로필 편집 화면은 준비 중이에요')}
                       style={({ pressed }) => [s.editBtn, { backgroundColor: dark ? T.dark.bg : T.light.bg }, pressed && { opacity: 0.8 }]}>
              <Text style={{ fontSize: 12.5, fontWeight: '700', color: T.accent }}>프로필 편집</Text>
            </Pressable>
          </Animated.View>

          <Group label="계정">
            <Row first icon="👤" iconBg="#E8F1FF" label="계정 정보" value="luna" onPress={() => {}} />
            <Row icon="🔒" iconBg="#EFEDFF" label="보안 및 로그인" onPress={() => {}} />
            <Row icon="🔗" iconBg="#FFF2E0" label="연결된 서비스" value="3개" onPress={() => {}} />
          </Group>

          <Group label="앱 설정">
            <Row first icon="🌙" iconBg="#E9E9EE" label="다크 모드" isSwitch swValue={dark} onSwitch={toggleDark} />
            <Row icon="🌐" iconBg="#E6F9EC" label="언어" value="한국어" onPress={() => {}} />
            <Row icon="🧹" iconBg="#E0F7F6" label="캐시 삭제" value={cache}
                 onPress={() => { setCache('0MB'); toast('캐시를 삭제했어요 (128MB)'); }} />
          </Group>

          <Group label="알림">
            <Row first icon="🔔" iconBg="#FFE9ED" label="푸시 알림" isSwitch swValue={push} onSwitch={setPush} />
            <Row icon="📣" iconBg="#FFF2E0" label="마케팅 알림" isSwitch swValue={marketing} onSwitch={setMarketing} />
            <Row icon="🌜" iconBg="#EFEDFF" label="야간 알림 제한" isSwitch swValue={night} onSwitch={setNight} />
          </Group>

          <Group label="정보">
            <Row first icon="📄" iconBg="#EEEEF2" label="이용약관" onPress={() => {}} />
            <Row icon="ℹ️" iconBg="#E3F4FF" label="버전 정보" value="v2.4.1 (최신)" />
            <Row icon="🚪" iconBg="#FFE9E7" label="로그아웃" danger onPress={() => setDlg(true)} />
          </Group>

          <Animated.Text style={[s.footNote, { color: col.sub }]}>
            루나 디자인 갤러리 · 대한민국{'\n'}© 2026 luna. All rights reserved.
          </Animated.Text>
        </ScrollView>

        {/* 로그아웃 확인 다이얼로그 */}
        <Modal visible={dlg} transparent animationType="fade" onRequestClose={() => setDlg(false)}>
          <Pressable style={s.dlgDim} onPress={() => setDlg(false)}>
            <Pressable style={[s.dlg, { backgroundColor: dark ? T.dark.card : T.light.card }]} onPress={() => {}}>
              <Text style={[s.dlgTitle, { color: dark ? T.dark.ink : T.light.ink }]}>로그아웃할까요?</Text>
              <Text style={[s.dlgBody, { color: dark ? T.dark.sub : T.light.sub }]}>
                로그아웃해도 계정 데이터는 안전하게 보관돼요. 언제든 다시 로그인할 수 있어요.
              </Text>
              <View style={[s.dlgBtns, { borderTopColor: dark ? T.dark.line : T.light.line }]}>
                <Pressable style={s.dlgBtn} onPress={() => setDlg(false)}>
                  <Text style={{ fontSize: 15, color: dark ? T.dark.ink : T.light.ink }}>취소</Text>
                </Pressable>
                <Pressable style={[s.dlgBtn, { borderLeftWidth: 1, borderLeftColor: dark ? T.dark.line : T.light.line }]}
                           onPress={() => { setDlg(false); toast('로그아웃 되었습니다'); }}>
                  <Text style={{ fontSize: 15, fontWeight: '700', color: T.danger }}>로그아웃</Text>
                </Pressable>
              </View>
            </Pressable>
          </Pressable>
        </Modal>

        {/* 토스트 */}
        {!!toastMsg && (
          <View style={s.toast}><Text style={{ color: '#FFF', fontSize: 13 }}>{toastMsg}</Text></View>
        )}
      </SafeAreaView>
    </Animated.View>
  );
}

const s = StyleSheet.create({
  navTitle: { fontSize: 26, fontWeight: '900', letterSpacing: -0.6, paddingHorizontal: 20,
              paddingTop: 8, paddingBottom: 6 },
  profile: { flexDirection: 'row', alignItems: 'center', gap: 14, borderRadius: T.radiusProfile,
             padding: 16, marginTop: 10 },
  avatar: { width: T.avatar, height: T.avatar, borderRadius: T.avatar / 2, backgroundColor: T.accent,
            alignItems: 'center', justifyContent: 'center' },
  profileName: { fontSize: 17, fontWeight: '800' },
  profileEmail: { marginTop: 3, fontSize: 12.5 },
  editBtn: { borderRadius: 99, paddingVertical: 8, paddingHorizontal: 13 },
  groupLabel: { marginTop: 20, marginBottom: 7, marginHorizontal: 6, fontSize: 12.5, fontWeight: '500' },
  group: { borderRadius: T.radiusGroup, overflow: 'hidden' },
  row: { flexDirection: 'row', alignItems: 'center', gap: 12, paddingVertical: 9, paddingHorizontal: 14,
         minHeight: 52 },
  icTile: { width: T.iconTile, height: T.iconTile, borderRadius: T.radiusIcon,
            alignItems: 'center', justifyContent: 'center' },
  rowLabel: { flex: 1, fontSize: 14.5 },
  rowValue: { fontSize: 13 },
  chev: { color: '#C7C7CC', fontSize: 15, marginLeft: 2 },
  footNote: { textAlign: 'center', marginTop: 22, fontSize: 11.5, lineHeight: 20 },
  dlgDim: { flex: 1, backgroundColor: 'rgba(0,0,0,.42)', alignItems: 'center', justifyContent: 'center' },
  dlg: { width: T.dialogW, borderRadius: T.radiusDialog, overflow: 'hidden' },
  dlgTitle: { textAlign: 'center', paddingTop: 20, paddingBottom: 7, fontSize: 16, fontWeight: '700' },
  dlgBody: { textAlign: 'center', paddingHorizontal: 22, paddingBottom: 18, fontSize: 12.5, lineHeight: 20 },
  dlgBtns: { flexDirection: 'row', borderTopWidth: 1 },
  dlgBtn: { flex: 1, paddingVertical: 13, alignItems: 'center' },
  toast: { position: 'absolute', bottom: 84, alignSelf: 'center', backgroundColor: 'rgba(28,28,30,.94)',
           borderRadius: 99, paddingVertical: 11, paddingHorizontal: 18 },
});
