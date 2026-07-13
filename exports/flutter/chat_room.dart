// Copyright (c) 2026 hyunaeee · MIT License — see /LICENSE at the project root.
// ─────────────────────────────────────────────────────────────
// chat_room.dart — 채팅 UI · 메신저 스타일 (Flutter)
// 용도: 말풍선/읽음 표시/날짜 구분선/타이핑 인디케이터/입력바,
//       전송 → 상대 타이핑 → 자동 답장 데모
// 실행: https://dartpad.dev 새 Flutter 스니펫에 파일 전체를 붙여넣고 Run
//       (flutter/material.dart + dart:async + dart:math 만 사용 — 외부 패키지 없음)
// 토큰: exports/tokens/chat.tokens.json 과 1:1 대응 (class T)
// ─────────────────────────────────────────────────────────────
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() => runApp(const ChatApp());

/* ── 디자인 토큰 (chat.tokens.json) ── */
class T {
  static const bg = Color(0xFFB2C7DA); //      color.background — 대화방 배경
  static const mine = Color(0xFFFFE812); //    color.bubble-mine
  static const other = Color(0xFFFFFFFF); //   color.bubble-other
  static const ink = Color(0xFF1E2226); //     color.text-primary
  static const sub = Color(0xFF67717C); //     color.text-secondary
  static const read = Color(0xFFF7B500); //    color.read-badge — 읽음(1)
  static const field = Color(0xFFF2F4F6); //   color.input-field
  static const double radiusBubble = 16; //    radius.bubble
  static const double radiusTail = 4; //       radius.bubble-tail
  static const double radiusAvatar = 13; //    radius.avatar — 스쿼클
}

const kReplies = [
  '오 방금 그거 코드 복사해서 써봐야지 📋',
  'ㅋㅋㅋ 타이핑 인디케이터까지 있는 거 실화냐',
  '이 정도면 그냥 웹소켓만 붙이면 되겠는데?',
  '읽음 표시 노란 숫자 디테일 좋다 👍',
];

class Msg {
  const Msg({required this.mine, required this.text, required this.time, this.read = false});
  final bool mine;
  final String text, time;
  final bool read;
}

String timeNow() {
  final d = DateTime.now();
  final h = d.hour;
  final hh = h % 12 == 0 ? 12 : h % 12;
  return '${h < 12 ? '오전' : '오후'} $hh:${d.minute.toString().padLeft(2, '0')}';
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: T.bg),
        home: const ChatRoom(),
      );
}

class ChatRoom extends StatefulWidget {
  const ChatRoom({super.key});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final _msgs = <Msg>[
    const Msg(mine: false, text: '디자인 갤러리에 앱 섹션 추가한 거 봤어? 👀', time: '오후 2:31'),
    const Msg(mine: true, text: '응! 폰 프레임 안에서 진짜로 동작하더라', time: '오후 2:32', read: true),
    const Msg(mine: true, text: '바텀시트도 열리고 캐러셀도 돌아가고 ㅋㅋ', time: '오후 2:32'),
    const Msg(mine: false, text: '이 채팅도 데모야. 아래에 입력해서 보내봐!', time: '오후 2:33'),
  ];
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _typing = false;
  int _replyIdx = 0;

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }

  /* 전송 → 700ms 후 타이핑 인디케이터 → 1400ms 후 자동 답장
     (실제 앱에서는 이 블록을 웹소켓 send/onmessage 로 교체) */
  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _inputCtrl.clear();
      _msgs.add(Msg(mine: true, text: text, time: timeNow(), read: true));
    });
    _scrollToEnd();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _typing = true);
      _scrollToEnd();
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        setState(() {
          _typing = false;
          _msgs.add(Msg(
              mine: false, text: kReplies[_replyIdx++ % kReplies.length], time: timeNow()));
        });
        _scrollToEnd();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(children: [
          // ── 대화방 헤더 ──
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
            child: Row(children: [
              const Text('‹', style: TextStyle(fontSize: 20, color: T.ink)),
              const SizedBox(width: 12),
              _avatar(38, 15, 18),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('루나', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: T.ink)),
                  Text('보통 몇 분 내 응답', style: TextStyle(fontSize: 11.5, color: T.sub)),
                ]),
              ),
              const Text('🔍', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 16),
              const Text('☰', style: TextStyle(fontSize: 18, color: T.ink)),
            ]),
          ),
          // ── 메시지 로그 ──
          Expanded(
            child: ListView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              children: [
                // 날짜 구분선
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0x381E2226), // rgba(30,34,38,.22)
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Text('2026년 7월 10일 금요일',
                        style: TextStyle(fontSize: 11, color: Colors.white)),
                  ),
                ),
                for (final m in _msgs) _msgRow(m),
                if (_typing) _typingRow(),
              ],
            ),
          ),
          // ── 입력바 ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 26),
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                width: 36, height: 36, alignment: Alignment.center,
                decoration: const BoxDecoration(color: T.field, shape: BoxShape.circle),
                child: const Text('＋', style: TextStyle(fontSize: 18, color: T.sub)),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(15, 4, 8, 4),
                  decoration: BoxDecoration(color: T.field, borderRadius: BorderRadius.circular(20)),
                  child: Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _inputCtrl,
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _send(),
                        textInputAction: TextInputAction.send,
                        style: const TextStyle(fontSize: 14.5, color: T.ink),
                        decoration: const InputDecoration(
                          hintText: '메시지 보내기',
                          hintStyle: TextStyle(fontSize: 14.5, color: T.sub),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    const Opacity(opacity: .55, child: Text('😊', style: TextStyle(fontSize: 17))),
                  ]),
                ),
              ),
              const SizedBox(width: 9),
              // 전송 버튼: 입력이 있으면 노란색 활성 (.send.ready)
              GestureDetector(
                onTap: _send,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36, height: 36, alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _inputCtrl.text.trim().isNotEmpty ? T.mine : const Color(0xFFE9EBEE),
                    shape: BoxShape.circle,
                  ),
                  child: Text('➤',
                      style: TextStyle(
                        fontSize: 15,
                        color: _inputCtrl.text.trim().isNotEmpty ? T.ink : const Color(0xFFB0B8C1),
                      )),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  static Widget _avatar(double size, double radius, double fontSize) => Container(
        width: size, height: size, alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFFFFB75E), Color(0xFFED8F03)]),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Text('🐹', style: TextStyle(fontSize: fontSize)),
      );

  /* 말풍선 행 — 내 메시지는 우측 노랑 + 읽음(1), 상대는 아바타/이름 + 흰색 */
  Widget _msgRow(Msg m) {
    final bubble = Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .68),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: m.mine ? T.mine : T.other,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(m.mine ? T.radiusBubble : T.radiusTail),
          topRight: Radius.circular(m.mine ? T.radiusTail : T.radiusBubble),
          bottomLeft: const Radius.circular(T.radiusBubble),
          bottomRight: const Radius.circular(T.radiusBubble),
        ),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Text(m.text, style: const TextStyle(fontSize: 14, height: 1.5, color: T.ink)),
    );

    final meta = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (m.mine && m.read)
          const Text('1', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: T.read)),
        Text(m.time, style: const TextStyle(fontSize: 10, color: T.sub)),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: m.mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: m.mine
            ? [meta, const SizedBox(width: 8), bubble]
            : [
                Align(alignment: Alignment.topLeft, child: _avatar(34, T.radiusAvatar, 16)),
                const SizedBox(width: 8),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('루나', style: TextStyle(fontSize: 11.5, color: T.sub)),
                  const SizedBox(height: 3),
                  bubble,
                ]),
                const SizedBox(width: 8),
                meta,
              ],
      ),
    );
  }

  Widget _typingRow() => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Align(alignment: Alignment.topLeft, child: _avatar(34, T.radiusAvatar, 16)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            decoration: BoxDecoration(
              color: T.other,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(T.radiusTail),
                topRight: Radius.circular(T.radiusBubble),
                bottomLeft: Radius.circular(T.radiusBubble),
                bottomRight: Radius.circular(T.radiusBubble),
              ),
            ),
            child: const _TypingDots(),
          ),
        ]),
      );
}

/* 타이핑 인디케이터 — 원본 @keyframes tw (점 3개가 순차로 튀어오름) 재현 */
class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = (_ctrl.value - i * .15) % 1.0;
            final phase = t < 0 ? t + 1.0 : t;
            final dy = phase < .6 ? -5.0 * math.sin(phase / .6 * math.pi) : 0.0;
            return Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : 5),
              child: Transform.translate(
                offset: Offset(0, dy),
                child: Container(
                  width: 7, height: 7,
                  decoration:
                      const BoxDecoration(color: Color(0xFFB9C0C8), shape: BoxShape.circle),
                ),
              ),
            );
          }),
        ),
      );
}
