// Copyright (c) 2026 hyunaeee · MIT License — see /LICENSE at the project root.
//
//  ChatRoom.swift — 채팅 UI · 메신저 스타일 (SwiftUI, iOS 17)
//  용도: 말풍선/읽음 표시/날짜 구분선/타이핑 인디케이터/입력바,
//        전송 → 상대 타이핑 → 자동 답장 데모
//  사용법: Xcode 프로젝트에 새 Swift 파일로 그대로 붙여넣기 → 캔버스 #Preview 즉시 동작
//  토큰: exports/tokens/chat.tokens.json 과 1:1 대응 (extension Color)
//

import SwiftUI

// MARK: - 디자인 토큰 (chat.tokens.json)
extension Color {
    static let chatBG    = Color(red: 178/255, green: 199/255, blue: 218/255) // #B2C7DA — 대화방 배경
    static let chatMine  = Color(red: 255/255, green: 232/255, blue: 18/255)  // #FFE812 — 내 말풍선
    static let chatInk   = Color(red: 30/255,  green: 34/255,  blue: 38/255)  // #1E2226
    static let chatSub   = Color(red: 103/255, green: 113/255, blue: 124/255) // #67717C
    static let chatRead  = Color(red: 247/255, green: 181/255, blue: 0/255)   // #F7B500 — 읽음(1)
    static let chatField = Color(red: 242/255, green: 244/255, blue: 246/255) // #F2F4F6 — 입력 필드
}

// MARK: - 데이터
struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let mine: Bool
    let text: String
    let time: String
    var read = false
}

private let replies = [
    "오 방금 그거 코드 복사해서 써봐야지 📋",
    "ㅋㅋㅋ 타이핑 인디케이터까지 있는 거 실화냐",
    "이 정도면 그냥 웹소켓만 붙이면 되겠는데?",
    "읽음 표시 노란 숫자 디테일 좋다 👍",
]

private func timeNow() -> String {
    let comps = Calendar.current.dateComponents([.hour, .minute], from: Date())
    let h = comps.hour ?? 0
    let hh = h % 12 == 0 ? 12 : h % 12
    return String(format: "%@ %d:%02d", h < 12 ? "오전" : "오후", hh, comps.minute ?? 0)
}

// MARK: - 메인 뷰
struct ChatRoom: View {
    @State private var messages: [ChatMessage] = [
        .init(mine: false, text: "디자인 갤러리에 앱 섹션 추가한 거 봤어? 👀", time: "오후 2:31"),
        .init(mine: true,  text: "응! 폰 프레임 안에서 진짜로 동작하더라", time: "오후 2:32", read: true),
        .init(mine: true,  text: "바텀시트도 열리고 캐러셀도 돌아가고 ㅋㅋ", time: "오후 2:32"),
        .init(mine: false, text: "이 채팅도 데모야. 아래에 입력해서 보내봐!", time: "오후 2:33"),
    ]
    @State private var input = ""
    @State private var typing = false
    @State private var replyIdx = 0

    var body: some View {
        VStack(spacing: 0) {
            header
            log
            inputBar
        }
        .background(Color.chatBG)
    }

    // MARK: 대화방 헤더
    private var header: some View {
        HStack(spacing: 12) {
            Text("‹").font(.system(size: 20)).foregroundStyle(Color.chatInk)
            avatar(size: 38, radius: 15, fontSize: 18)
            VStack(alignment: .leading, spacing: 1) {
                Text("루나").font(.system(size: 15.5, weight: .bold)).foregroundStyle(Color.chatInk)
                Text("보통 몇 분 내 응답").font(.system(size: 11.5)).foregroundStyle(Color.chatSub)
            }
            Spacer()
            Text("🔍").font(.system(size: 18))
            Text("☰").font(.system(size: 18)).foregroundStyle(Color.chatInk)
        }
        .padding(.horizontal, 18)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    // MARK: 메시지 로그 (자동 스크롤)
    private var log: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 10) {
                    // 날짜 구분선
                    Text("2026년 7월 10일 금요일")
                        .font(.system(size: 11))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 5)
                        .background(Color.chatInk.opacity(0.22), in: Capsule())
                        .padding(.top, 10)
                        .padding(.bottom, 4)
                    ForEach(messages) { msg in
                        messageRow(msg).id(msg.id)
                    }
                    if typing {
                        typingRow.id("typing")
                    }
                    Color.clear.frame(height: 1).id("bottom")
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
            }
            .onChange(of: messages) {
                withAnimation(.easeOut(duration: 0.25)) { proxy.scrollTo("bottom") }
            }
            .onChange(of: typing) {
                withAnimation(.easeOut(duration: 0.25)) { proxy.scrollTo("bottom") }
            }
        }
    }

    // MARK: 말풍선 행 (내 메시지 = 우측 노랑 + 읽음 1, 상대 = 아바타/이름 + 흰색)
    private func messageRow(_ msg: ChatMessage) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            if msg.mine {
                Spacer(minLength: 60)
                metaColumn(msg)
                bubble(msg)
            } else {
                avatar(size: 34, radius: 13, fontSize: 16)   // radius.avatar — 스쿼클
                    .frame(maxHeight: .infinity, alignment: .top)
                VStack(alignment: .leading, spacing: 3) {
                    Text("루나").font(.system(size: 11.5)).foregroundStyle(Color.chatSub)
                    bubble(msg)
                }
                metaColumn(msg)
                Spacer(minLength: 60)
            }
        }
        .transition(.asymmetric(insertion: .scale(scale: 0.96).combined(with: .opacity)
                                            .combined(with: .offset(y: 10)),
                                removal: .opacity))
    }

    private func bubble(_ msg: ChatMessage) -> some View {
        Text(msg.text)
            .font(.system(size: 14))
            .lineSpacing(3)
            .foregroundStyle(Color.chatInk)
            .padding(.horizontal, 13)   // spacing.bubble-x
            .padding(.vertical, 10)     // spacing.bubble-y
            .background(msg.mine ? Color.chatMine : .white)
            .clipShape(BubbleShape(mine: msg.mine))     // radius.bubble 16 / bubble-tail 4
            .shadow(color: .black.opacity(0.06), radius: 1, y: 1)
    }

    private func metaColumn(_ msg: ChatMessage) -> some View {
        VStack(alignment: .trailing, spacing: 1) {
            if msg.mine && msg.read {
                Text("1").font(.system(size: 10, weight: .bold)).foregroundStyle(Color.chatRead)
            }
            Text(msg.time).font(.system(size: 10)).foregroundStyle(Color.chatSub)
        }
    }

    // MARK: 타이핑 인디케이터
    private var typingRow: some View {
        HStack(alignment: .bottom, spacing: 8) {
            avatar(size: 34, radius: 13, fontSize: 16)
                .frame(maxHeight: .infinity, alignment: .top)
            TypingDots()
                .padding(.horizontal, 15)
                .padding(.vertical, 13)
                .background(.white)
                .clipShape(BubbleShape(mine: false))
            Spacer(minLength: 60)
        }
        .transition(.opacity)
    }

    // MARK: 입력바
    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: 9) {
            Button {} label: {
                Text("＋").font(.system(size: 18)).foregroundStyle(Color.chatSub)
                    .frame(width: 36, height: 36)
                    .background(Color.chatField, in: Circle())
            }
            .buttonStyle(.plain)
            HStack(spacing: 8) {
                TextField("메시지 보내기", text: $input)
                    .font(.system(size: 14.5))
                    .foregroundStyle(Color.chatInk)
                    .onSubmit(send)
                Text("😊").font(.system(size: 17)).opacity(0.55)
            }
            .padding(.leading, 15)
            .padding(.trailing, 8)
            .padding(.vertical, 8)
            .background(Color.chatField, in: RoundedRectangle(cornerRadius: 20)) // radius.input
            // 전송 버튼 — 입력이 있으면 노란색 활성 (.send.ready)
            Button(action: send) {
                Text("➤")
                    .font(.system(size: 15))
                    .foregroundStyle(input.trimmingCharacters(in: .whitespaces).isEmpty
                                     ? Color(red: 176/255, green: 184/255, blue: 193/255)
                                     : Color.chatInk)
                    .frame(width: 36, height: 36)
                    .background(input.trimmingCharacters(in: .whitespaces).isEmpty
                                ? Color(red: 233/255, green: 235/255, blue: 238/255)
                                : Color.chatMine,
                                in: Circle())
            }
            .buttonStyle(.plain)
            .animation(.easeOut(duration: 0.2), value: input.isEmpty)
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(.white)
    }

    // MARK: 전송 → 0.7초 후 타이핑 → 1.4초 후 자동 답장
    //       (실제 앱에서는 이 블록을 웹소켓 send/onmessage 로 교체)
    private func send() {
        let text = input.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        input = ""
        withAnimation(.spring(duration: 0.35)) {
            messages.append(.init(mine: true, text: text, time: timeNow(), read: true))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation { typing = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                withAnimation(.spring(duration: 0.35)) {
                    typing = false
                    messages.append(.init(mine: false,
                                          text: replies[replyIdx % replies.count],
                                          time: timeNow()))
                    replyIdx += 1
                }
            }
        }
    }

    private func avatar(size: CGFloat, radius: CGFloat, fontSize: CGFloat) -> some View {
        Text("🐹")
            .font(.system(size: fontSize))
            .frame(width: size, height: size)
            .background(
                LinearGradient(colors: [Color(red: 255/255, green: 183/255, blue: 94/255),   // #FFB75E
                                        Color(red: 237/255, green: 143/255, blue: 3/255)],   // #ED8F03
                               startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: radius)
            )
    }
}

// MARK: - 말풍선 모양 (꼬리쪽 모서리만 4pt)
struct BubbleShape: Shape {
    let mine: Bool
    func path(in rect: CGRect) -> Path {
        let radii = RectangleCornerRadii(
            topLeading: mine ? 16 : 4,
            bottomLeading: 16,
            bottomTrailing: 16,
            topTrailing: mine ? 4 : 16
        )
        return UnevenRoundedRectangle(cornerRadii: radii).path(in: rect)
    }
}

// MARK: - 타이핑 점 3개 (순차 바운스)
struct TypingDots: View {
    @State private var up = false
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color(red: 185/255, green: 192/255, blue: 200/255)) // #B9C0C8
                    .frame(width: 7, height: 7)
                    .offset(y: up ? -5 : 0)
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.18),
                               value: up)
            }
        }
        .onAppear { up = true }
    }
}

#Preview {
    ChatRoom()
}
