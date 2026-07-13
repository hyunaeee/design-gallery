// Copyright (c) 2026 hyunaeee · MIT License — see /LICENSE at the project root.
//
//  Onboarding.swift — 온보딩 → 로그인 플로우 (SwiftUI, iOS 17)
//  용도: 3장 캐러셀 온보딩(TabView .page + dots) → 마지막 장/건너뛰기에서
//        소셜 로그인 화면 전환 ('마지막 로그인' 뱃지 포함)
//  사용법: Xcode 프로젝트에 새 Swift 파일로 그대로 붙여넣기 → 캔버스 #Preview 즉시 동작
//  토큰: exports/tokens/onboarding.tokens.json 과 1:1 대응 (extension Color)
//

import SwiftUI

// MARK: - 디자인 토큰 (onboarding.tokens.json)
extension Color {
    static let obPrimary   = Color(red: 108/255, green: 92/255,  blue: 231/255) // #6C5CE7 — 브랜드 바이올렛
    static let obInk       = Color(red: 29/255,  green: 27/255,  blue: 46/255)  // #1D1B2E
    static let obSub       = Color(red: 140/255, green: 136/255, blue: 163/255) // #8C88A3
    static let obDotOff    = Color(red: 227/255, green: 224/255, blue: 240/255) // #E3E0F0
    static let obKakao     = Color(red: 254/255, green: 229/255, blue: 0/255)   // #FEE500
    static let obNaver     = Color(red: 3/255,   green: 199/255, blue: 90/255)  // #03C75A
    static let obApple     = Color(red: 17/255,  green: 17/255,  blue: 17/255)  // #111111
    static let obEmail     = Color(red: 242/255, green: 242/255, blue: 247/255) // #F2F2F7
    static let obLastLogin = Color(red: 255/255, green: 71/255,  blue: 87/255)  // #FF4757 — 마지막 로그인 뱃지
}

// MARK: - 데이터
struct ObSlide: Identifiable {
    let id = UUID()
    let emoji: String
    let bg: [Color]
    let title: String
    let body: String
}

private let slides: [ObSlide] = [
    .init(emoji: "🗂️",
          bg: [Color(red: 236/255, green: 233/255, blue: 251/255), Color(red: 220/255, green: 214/255, blue: 247/255)],
          title: "흩어진 디자인 레퍼런스,\n한 곳에 모아요",
          body: "웹과 앱, 패턴과 컴포넌트별로 정리된\n레퍼런스를 검색 한 번으로 찾으세요."),
    .init(emoji: "⚡",
          bg: [Color(red: 224/255, green: 247/255, blue: 245/255), Color(red: 197/255, green: 237/255, blue: 233/255)],
          title: "보기만 하지 말고\n바로 코드로 쓰세요",
          body: "모든 레퍼런스는 동작하는 코드와 함께.\n복사해서 프로젝트에 붙여넣으면 끝."),
    .init(emoji: "🤝",
          bg: [Color(red: 255/255, green: 242/255, blue: 224/255), Color(red: 255/255, green: 227/255, blue: 194/255)],
          title: "팀과 함께 쓰면\n더 강력해져요",
          body: "컬렉션을 만들어 공유하고\n우리 팀의 디자인 언어를 만들어 가세요."),
]

struct SocialButton: Identifiable {
    let id = UUID()
    let label: String
    let bg: Color
    let fg: Color
    var last = false
}

private let socials: [SocialButton] = [
    .init(label: "💬 카카오로 계속하기", bg: .obKakao, fg: Color(red: 25/255, green: 22/255, blue: 0/255), last: true),
    .init(label: "N 네이버로 계속하기", bg: .obNaver, fg: .white),
    .init(label: " Apple로 계속하기", bg: .obApple, fg: .white),
    .init(label: "✉️ 이메일로 계속하기", bg: .obEmail, fg: .obInk),
]

// MARK: - 메인 뷰 (온보딩 ↔ 로그인 전환)
struct Onboarding: View {
    @State private var idx = 0
    @State private var showLogin = false

    var body: some View {
        ZStack {
            if showLogin {
                loginView
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)))
            } else {
                onboardingView
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)))
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showLogin)
        .background(Color.white)
    }

    // MARK: 온보딩 캐러셀
    private var onboardingView: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("건너뛰기") { showLogin = true }
                    .font(.system(size: 13.5))
                    .foregroundStyle(Color.obSub)
            }
            .padding(.horizontal, 22)
            .padding(.top, 14)

            // 스와이프 가능한 3장 캐러셀
            TabView(selection: $idx) {
                ForEach(0..<slides.count, id: \.self) { i in
                    slideView(slides[i]).tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            VStack(spacing: 20) {
                // 페이지 dots — 활성 dot 은 22pt 캡슐로 확장
                HStack(spacing: 7) {
                    ForEach(0..<slides.count, id: \.self) { i in
                        Capsule()
                            .fill(idx == i ? Color.obPrimary : Color.obDotOff)
                            .frame(width: idx == i ? 22 : 7, height: 7)  // component.dot-active-w
                            .animation(.easeOut(duration: 0.3), value: idx)
                    }
                }
                // '다음' → 마지막 장이면 '시작하기' → 로그인 전환
                Button {
                    if idx < slides.count - 1 {
                        withAnimation(.easeOut(duration: 0.4)) { idx += 1 }
                    } else {
                        showLogin = true
                    }
                } label: {
                    Text(idx == slides.count - 1 ? "시작하기" : "다음")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.obPrimary, in: RoundedRectangle(cornerRadius: 16)) // radius.cta
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 26)  // spacing.screen-x
            .padding(.top, 12)
            .padding(.bottom, 42)      // spacing.cta-bottom
        }
    }

    private func slideView(_ slide: ObSlide) -> some View {
        VStack(spacing: 0) {
            Text(slide.emoji)
                .font(.system(size: 88))
                .frame(width: 220, height: 220)                            // component.art-size
                .background(
                    LinearGradient(colors: slide.bg, startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: 64)                 // radius.art
                )
                .padding(.bottom, 44)
            Text(slide.title)
                .font(.system(size: 25, weight: .black))
                .foregroundStyle(Color.obInk)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
            Text(slide.body)
                .font(.system(size: 14.5))
                .foregroundStyle(Color.obSub)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .padding(.top, 13)
        }
        .padding(.horizontal, 34)
    }

    // MARK: 로그인 화면 (소셜 버튼 + '마지막 로그인' 뱃지)
    private var loginView: some View {
        VStack(spacing: 0) {
            HStack {
                Button { showLogin = false } label: {
                    Text("‹").font(.system(size: 22)).foregroundStyle(Color.obSub)
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .padding(.horizontal, 22)
            .padding(.top, 14)

            // 히어로
            Text("◈")
                .font(.system(size: 38))
                .foregroundStyle(.white)
                .frame(width: 76, height: 76)
                .background(
                    LinearGradient(colors: [Color.obPrimary,
                                            Color(red: 162/255, green: 155/255, blue: 254/255)], // #A29BFE
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: 26)
                )
                .shadow(color: Color.obPrimary.opacity(0.55), radius: 17, y: 12)
                .padding(.top, 60)
            Text("디자인 갤러리 시작하기")
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(Color.obInk)
                .padding(.top, 24)
            Text("3초 만에 가입하고 모든 레퍼런스를 저장하세요")
                .font(.system(size: 13.5))
                .foregroundStyle(Color.obSub)
                .padding(.top, 8)

            // 소셜 로그인 버튼
            VStack(spacing: 11) {  // spacing.social-gap
                ForEach(socials) { social in
                    Button {} label: {
                        Text(social.label)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(social.fg)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)                              // component.social-height
                            .background(social.bg, in: RoundedRectangle(cornerRadius: 14)) // radius.social
                    }
                    .buttonStyle(.plain)
                    .overlay(alignment: .topTrailing) {
                        if social.last {
                            Text("마지막 로그인")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 3)
                                .background(
                                    Color.obLastLogin,
                                    in: UnevenRoundedRectangle(cornerRadii: .init(
                                        topLeading: 99, bottomLeading: 3,
                                        bottomTrailing: 99, topTrailing: 99))
                                )
                                .offset(x: -14, y: -9)
                        }
                    }
                }
            }
            .padding(.horizontal, 26)
            .padding(.top, 40)

            Spacer()

            (Text("이미 계정이 있나요? ")
                .foregroundColor(.obSub)
             + Text("로그인")
                .foregroundColor(.obPrimary)
                .fontWeight(.bold))
                .font(.system(size: 12.5))
                .padding(.bottom, 44)
        }
    }
}

#Preview {
    Onboarding()
}
