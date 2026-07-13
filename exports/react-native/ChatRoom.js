// Copyright (c) 2026 hyunaeee · MIT License — see /LICENSE at the project root.
/**
 * 채팅 UI — 메신저 스타일 (React Native)
 * 의존성: react-native 코어만 사용 — Expo Snack에 그대로 붙여넣어 실행 가능
 * 실제 동작: 전송 → 상대 타이핑 인디케이터 → 자동 답장 (웹소켓으로 교체 지점 주석 참고)
 * 토큰: exports/tokens/chat.tokens.json 과 1:1 대응
 */
import React, { useRef, useState } from 'react';
import {
  SafeAreaView, FlatList, View, Text, TextInput, Pressable,
  KeyboardAvoidingView, Platform, StyleSheet,
} from 'react-native';

/* ── 디자인 토큰 (chat.tokens.json) ── */
const T = {
  bg: '#B2C7DA', mine: '#FFE812', other: '#FFFFFF',
  ink: '#1E2226', sub: '#67717C', read: '#F7B500', field: '#F2F4F6',
  radiusBubble: 16, radiusTail: 4,
};

const REPLIES = [
  '오 방금 그거 코드 복사해서 써봐야지 📋',
  'ㅋㅋㅋ RN 버전도 있는 거 실화냐',
  '이 정도면 그냥 웹소켓만 붙이면 되겠는데?',
  '읽음 표시 노란 숫자 디테일 좋다 👍',
];

const timeNow = () => {
  const d = new Date(); const h = d.getHours();
  return `${h < 12 ? '오전' : '오후'} ${h % 12 || 12}:${String(d.getMinutes()).padStart(2, '0')}`;
};

const INITIAL = [
  { id: '1', mine: false, text: 'RN 버전 채팅 UI야. 아래에 입력해서 보내봐!', time: '오후 2:31' },
  { id: '2', mine: true, text: '오 진짜 카톡같이 생겼다', time: '오후 2:32', read: true },
];

export default function ChatRoom() {
  const [msgs, setMsgs] = useState(INITIAL);
  const [text, setText] = useState('');
  const [typing, setTyping] = useState(false);
  const listRef = useRef(null);
  const replyIdx = useRef(0);

  const scrollEnd = () => setTimeout(() => listRef.current?.scrollToEnd({ animated: true }), 60);

  const send = () => {
    const t = text.trim();
    if (!t) return;
    setText('');
    setMsgs(m => [...m, { id: String(Date.now()), mine: true, text: t, time: timeNow(), read: true }]);
    scrollEnd();
    /* ⇩ 실제 앱에서는 이 블록을 웹소켓 send/onmessage 로 교체 */
    setTimeout(() => {
      setTyping(true); scrollEnd();
      setTimeout(() => {
        setTyping(false);
        setMsgs(m => [...m, { id: String(Date.now() + 1), mine: false,
          text: REPLIES[replyIdx.current++ % REPLIES.length], time: timeNow() }]);
        scrollEnd();
      }, 1400);
    }, 700);
  };

  const renderMsg = ({ item }) => (
    <View style={[s.row, item.mine && s.rowMine]}>
      {!item.mine && <View style={s.avatar}><Text style={{ fontSize: 16 }}>🐹</Text></View>}
      <View style={{ maxWidth: '68%' }}>
        {!item.mine && <Text style={s.name}>루나</Text>}
        <View style={[s.bubble, item.mine ? s.bubbleMine : s.bubbleOther]}>
          <Text style={s.bubbleText}>{item.text}</Text>
        </View>
      </View>
      <View style={s.metaCol}>
        {item.mine && item.read && <Text style={s.read}>1</Text>}
        <Text style={s.time}>{item.time}</Text>
      </View>
    </View>
  );

  return (
    <SafeAreaView style={s.root}>
      {/* 대화방 헤더 */}
      <View style={s.head}>
        <Text style={{ fontSize: 20 }}>‹</Text>
        <View style={s.headAvatar}><Text style={{ fontSize: 18 }}>🐹</Text></View>
        <View style={{ flex: 1 }}>
          <Text style={s.headName}>루나</Text>
          <Text style={s.headSub}>보통 몇 분 내 응답</Text>
        </View>
        <Text style={{ fontSize: 16 }}>🔍  ☰</Text>
      </View>

      <FlatList
        ref={listRef} data={msgs} keyExtractor={m => m.id} renderItem={renderMsg}
        contentContainerStyle={{ padding: 14 }}
        ListHeaderComponent={
          <View style={s.day}><Text style={s.dayText}>2026년 7월 10일 금요일</Text></View>}
        ListFooterComponent={typing ? (
          <View style={s.row}>
            <View style={s.avatar}><Text style={{ fontSize: 16 }}>🐹</Text></View>
            <View style={[s.bubble, s.bubbleOther]}>
              <Text style={{ color: '#B9C0C8', letterSpacing: 2 }}>● ● ●</Text>
            </View>
          </View>) : null}
      />

      {/* 입력바 */}
      <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
        <View style={s.inputbar}>
          <Pressable style={s.plus}><Text style={{ color: T.sub, fontSize: 18 }}>＋</Text></Pressable>
          <View style={s.field}>
            <TextInput
              style={s.input} value={text} onChangeText={setText}
              placeholder="메시지 보내기" placeholderTextColor={T.sub}
              onSubmitEditing={send} returnKeyType="send"
            />
            <Text style={{ opacity: .55 }}>😊</Text>
          </View>
          <Pressable onPress={send}
            style={[s.sendBtn, text.trim() ? { backgroundColor: T.mine } : null]}>
            <Text style={{ color: text.trim() ? T.ink : '#B0B8C1', fontSize: 14 }}>➤</Text>
          </Pressable>
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const s = StyleSheet.create({
  root: { flex: 1, backgroundColor: T.bg },
  head: { flexDirection: 'row', alignItems: 'center', gap: 12,
          paddingHorizontal: 18, paddingVertical: 10 },
  headAvatar: { width: 38, height: 38, borderRadius: 15, backgroundColor: '#FFB75E',
                alignItems: 'center', justifyContent: 'center' },
  headName: { fontSize: 15.5, fontWeight: '700', color: T.ink },
  headSub: { fontSize: 11.5, color: T.sub },
  day: { alignItems: 'center', marginVertical: 12 },
  dayText: { fontSize: 11, color: '#fff', backgroundColor: 'rgba(30,34,38,.22)',
             paddingHorizontal: 14, paddingVertical: 5, borderRadius: 99, overflow: 'hidden' },
  row: { flexDirection: 'row', alignItems: 'flex-end', gap: 8, marginBottom: 10 },
  rowMine: { flexDirection: 'row-reverse' },
  avatar: { width: 34, height: 34, borderRadius: 13, backgroundColor: '#FFB75E',
            alignItems: 'center', justifyContent: 'center', alignSelf: 'flex-start' },
  name: { fontSize: 11.5, color: T.sub, marginBottom: 3 },
  bubble: { paddingHorizontal: 13, paddingVertical: 10, alignSelf: 'flex-start' },
  bubbleOther: { backgroundColor: T.other, borderRadius: T.radiusBubble, borderTopLeftRadius: T.radiusTail },
  bubbleMine: { backgroundColor: T.mine, borderRadius: T.radiusBubble, borderTopRightRadius: T.radiusTail,
                alignSelf: 'flex-end' },
  bubbleText: { fontSize: 14, lineHeight: 21, color: T.ink },
  metaCol: { alignItems: 'flex-end', gap: 1 },
  read: { fontSize: 10, color: T.read, fontWeight: '700' },
  time: { fontSize: 10, color: T.sub },
  inputbar: { flexDirection: 'row', alignItems: 'center', gap: 9, backgroundColor: '#fff',
              paddingHorizontal: 12, paddingTop: 10, paddingBottom: 26 },
  plus: { width: 36, height: 36, borderRadius: 18, backgroundColor: T.field,
          alignItems: 'center', justifyContent: 'center' },
  field: { flex: 1, flexDirection: 'row', alignItems: 'center', gap: 8,
           backgroundColor: T.field, borderRadius: 20, paddingLeft: 15, paddingRight: 10,
           paddingVertical: 8 },
  input: { flex: 1, fontSize: 14.5, color: T.ink, padding: 0 },
  sendBtn: { width: 36, height: 36, borderRadius: 18, backgroundColor: '#E9EBEE',
             alignItems: 'center', justifyContent: 'center' },
});
