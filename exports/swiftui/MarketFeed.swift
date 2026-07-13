// Copyright (c) 2026 hyunaeee · MIT License — see /LICENSE at the project root.
//
//  MarketFeed.swift — 중고거래 피드 · 당근 스타일 (SwiftUI, iOS 17)
//  용도: 동네 셀렉터 헤더, 칩 필터, 썸네일 리스트, 스크롤 시 접히는 확장형 FAB
//  사용법: Xcode 프로젝트에 새 Swift 파일로 그대로 붙여넣기 → 캔버스 #Preview 즉시 동작
//  토큰: exports/tokens/market.tokens.json 과 1:1 대응 (extension Color)
//

import SwiftUI

// MARK: - 디자인 토큰 (market.tokens.json)
extension Color {
    static let marketPrimary    = Color(red: 255/255, green: 111/255, blue: 15/255)  // #FF6F0F — 당근 오렌지
    static let marketInk        = Color(red: 33/255,  green: 33/255,  blue: 36/255)  // #212124
    static let marketSub        = Color(red: 134/255, green: 139/255, blue: 148/255) // #868B94
    static let marketDivider    = Color(red: 241/255, green: 243/255, blue: 245/255) // #F1F3F5
    static let marketChipBorder = Color(red: 233/255, green: 236/255, blue: 239/255) // #E9ECEF
    static let marketReserved   = Color(red: 29/255,  green: 125/255, blue: 69/255)  // #1D7D45 — 예약중 뱃지
}

// MARK: - 데이터
struct MarketItem: Identifiable {
    let id = UUID()
    let img: String
    let emoji: String
    let fallback: [Color]
    let title: String
    let area: String
    let price: String
    var reserved = false
    var free = false
    let likes: Int
    let chats: Int
}

private let chips = ["전체", "디지털기기", "가구/인테리어", "유아동", "생활가전", "의류"]

private let items: [MarketItem] = [
    .init(img: "https://picsum.photos/id/119/220/220", emoji: "💻",
          fallback: [Color(red: 223/255, green: 233/255, blue: 243/255), .white],
          title: "맥북 프로 14인치 M3 급처합니다", area: "역삼동 · 10분 전",
          price: "1,850,000원", likes: 12, chats: 5),
    .init(img: "https://picsum.photos/id/1080/220/220", emoji: "🪑",
          fallback: [Color(red: 251/255, green: 233/255, blue: 215/255), Color(red: 246/255, green: 213/255, blue: 184/255)],
          title: "원목 식탁 4인용 + 의자 세트", area: "대치동 · 32분 전",
          price: "120,000원", reserved: true, likes: 28, chats: 11),
    .init(img: "https://picsum.photos/id/96/220/220", emoji: "🌱",
          fallback: [Color(red: 232/255, green: 245/255, blue: 233/255), Color(red: 200/255, green: 230/255, blue: 201/255)],
          title: "몬스테라 대품 화분째로 드려요", area: "도곡동 · 1시간 전",
          price: "나눔 🧡", free: true, likes: 41, chats: 23),
    .init(img: "https://picsum.photos/id/175/220/220", emoji: "📷",
          fallback: [Color(red: 237/255, green: 231/255, blue: 246/255), Color(red: 209/255, green: 196/255, blue: 233/255)],
          title: "필름카메라 캐논 AE-1 작동 완벽", area: "역삼동 · 2시간 전",
          price: "230,000원", likes: 19, chats: 7),
    .init(img: "https://picsum.photos/id/21/220/220", emoji: "👟",
          fallback: [Color(red: 255/255, green: 243/255, blue: 224/255), Color(red: 255/255, green: 224/255, blue: 178/255)],
          title: "나이키 에어포스 270 새상품 (박스풀)", area: "삼성동 · 3시간 전",
          price: "89,000원", likes: 8, chats: 2),
]

private let tabs: [(icon: String, label: String)] = [
    ("🏠", "홈"), ("🗞️", "동네생활"), ("📍", "내 근처"), ("💬", "채팅"), ("👤", "나의 당근"),
]

// 스크롤 오프셋 감지용 PreferenceKey
private struct FeedOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

// MARK: - 메인 뷰
struct MarketFeed: View {
    @State private var chip = 0
    @State private var tab = 0
    @State private var fabWide = true                    // 스크롤 중 false → 멈추면 true
    @State private var lastOffset: CGFloat?
    @State private var expandWork: DispatchWorkItem?

    var body: some View {
        VStack(spacing: 0) {
            header
            chipFilter
            feed
            tabbar
        }
        .background(Color.white)
        .overlay(alignment: .bottomTrailing) { fab }
    }

    // MARK: 헤더 (동네 셀렉터 + 채팅 뱃지 3)
    private var header: some View {
        HStack(spacing: 17) {
            HStack(spacing: 5) {
                Text("역삼동").font(.system(size: 18, weight: .black)).foregroundStyle(Color.marketInk)
                Text("▼").font(.system(size: 12)).foregroundStyle(Color.marketSub)
            }
            Spacer()
            Text("🔍").font(.system(size: 19))
            Text("💬").font(.system(size: 19))
                .overlay(alignment: .topTrailing) {
                    Text("3")
                        .font(.system(size: 9.5, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 16, height: 16)
                        .background(Color.marketPrimary, in: Circle())
                        .offset(x: 8, y: -5)
                }
            Text("🔔").font(.system(size: 19))
        }
        .padding(.horizontal, 18)
        .padding(.top, 8)
        .padding(.bottom, 10)
    }

    // MARK: 칩 필터
    private var chipFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(0..<chips.count, id: \.self) { i in
                    Button { withAnimation(.easeOut(duration: 0.15)) { chip = i } } label: {
                        Text(chips[i])
                            .font(.system(size: 13, weight: chip == i ? .bold : .medium))
                            .foregroundStyle(chip == i ? .white : Color(red: 77/255, green: 81/255, blue: 89/255))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(chip == i ? Color.marketInk : .white, in: Capsule())
                            .overlay(Capsule().stroke(chip == i ? Color.marketInk : Color.marketChipBorder))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 4)
        }
        .padding(.bottom, 8)
        .overlay(alignment: .bottom) { Rectangle().fill(Color.marketDivider).frame(height: 1) }
    }

    // MARK: 피드 (스크롤 → FAB 접힘, 350ms 멈추면 펼침)
    private var feed: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(items) { item in feedCell(item) }
            }
            .background(
                GeometryReader { geo in
                    Color.clear.preference(key: FeedOffsetKey.self,
                                           value: geo.frame(in: .named("feed")).minY)
                }
            )
        }
        .coordinateSpace(name: "feed")
        .onPreferenceChange(FeedOffsetKey.self) { offset in
            guard let last = lastOffset else { lastOffset = offset; return }
            guard abs(offset - last) > 0.5 else { return }
            lastOffset = offset
            withAnimation(.easeOut(duration: 0.2)) { fabWide = false }
            expandWork?.cancel()
            let work = DispatchWorkItem {
                withAnimation(.spring(duration: 0.35)) { fabWide = true }
            }
            expandWork = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: work)
        }
    }

    // MARK: 리스트 셀 (썸네일 이모지 폴백 + 예약중/나눔 뱃지)
    private func feedCell(_ item: MarketItem) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                LinearGradient(colors: item.fallback, startPoint: .topLeading, endPoint: .bottomTrailing)
                Text(item.emoji).font(.system(size: 38))
                AsyncImage(url: URL(string: item.img)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.clear
                }
            }
            .frame(width: 108, height: 108)                            // component.thumbnail-size
            .clipShape(RoundedRectangle(cornerRadius: 12))              // radius.thumbnail
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 5) {
                    if item.reserved {
                        Text("예약중")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2.5)
                            .background(Color.marketReserved, in: RoundedRectangle(cornerRadius: 5))
                    }
                    Text(item.title)
                        .font(.system(size: 15))
                        .foregroundStyle(Color.marketInk)
                        .lineLimit(2)
                }
                Text(item.area)
                    .font(.system(size: 12.5)).foregroundStyle(Color.marketSub)
                    .padding(.top, 4)
                Text(item.price)
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(item.free ? Color.marketPrimary : Color.marketInk)
                    .padding(.top, 5)
                Spacer(minLength: 0)
                Text("♡ \(item.likes)   💬 \(item.chats)")
                    .font(.system(size: 12)).foregroundStyle(Color.marketSub)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(height: 108)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .overlay(alignment: .bottom) { Rectangle().fill(Color.marketDivider).frame(height: 1) }
    }

    // MARK: 확장형 FAB
    private var fab: some View {
        Button {} label: {
            HStack(spacing: 8) {
                Text("＋").font(.system(size: 21))
                if fabWide {
                    Text("글쓰기")
                        .font(.system(size: 15, weight: .bold))
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .frame(height: 54)                                          // component.fab-height
            .background(Color.marketPrimary, in: Capsule())
            .shadow(color: Color.marketPrimary.opacity(0.45), radius: 12, y: 10)
        }
        .buttonStyle(.plain)
        .padding(.trailing, 18)
        .padding(.bottom, 74)
    }

    // MARK: 탭바
    private var tabbar: some View {
        HStack {
            ForEach(0..<tabs.count, id: \.self) { i in
                Button { tab = i } label: {
                    VStack(spacing: 3) {
                        Text(tabs[i].icon).font(.system(size: 20)).opacity(tab == i ? 1 : 0.4)
                        Text(tabs[i].label)
                            .font(.system(size: 10.5, weight: tab == i ? .bold : .medium))
                            .foregroundStyle(tab == i ? Color.marketInk
                                                      : Color(red: 176/255, green: 184/255, blue: 193/255))
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(.regularMaterial)
        .overlay(alignment: .top) { Rectangle().fill(Color.marketDivider).frame(height: 1) }
    }
}

#Preview {
    MarketFeed()
}
