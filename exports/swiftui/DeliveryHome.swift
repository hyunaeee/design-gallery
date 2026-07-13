// Copyright (c) 2026 hyunaeee · MIT License — see /LICENSE at the project root.
//
//  DeliveryHome.swift — 배달 홈 · 배민 스타일 (SwiftUI, iOS 17)
//  용도: 민트 헤더+검색바, 카테고리 그리드(5열), 자동 순환 배너 캐러셀(TabView+Timer),
//        가로 스크롤 가게 카드, 주문 현황 플로팅 바, 5탭 탭바
//  사용법: Xcode 프로젝트에 새 Swift 파일로 그대로 붙여넣기 → 캔버스 #Preview 즉시 동작
//  토큰: exports/tokens/delivery.tokens.json 과 1:1 대응 (extension Color)
//

import SwiftUI

// MARK: - 디자인 토큰 (delivery.tokens.json)
extension Color {
    static let deliveryPrimary = Color(red: 42/255,  green: 193/255, blue: 188/255) // #2AC1BC — 브랜드 민트
    static let deliveryInk     = Color(red: 28/255,  green: 28/255,  blue: 30/255)  // #1C1C1E — text / order-bar
    static let deliverySub     = Color(red: 142/255, green: 142/255, blue: 147/255) // #8E8E93
    static let deliveryDivider = Color(red: 242/255, green: 242/255, blue: 247/255) // #F2F2F7
    static let deliveryStar    = Color(red: 255/255, green: 196/255, blue: 0/255)   // #FFC400
    static let deliveryCatBG   = Color(red: 247/255, green: 248/255, blue: 250/255) // #F7F8FA
}

// MARK: - 데이터
private let cats: [(emoji: String, label: String)] = [
    ("🍗", "치킨"), ("🍕", "피자"), ("🍜", "중식"), ("🍣", "회·초밥"), ("🍔", "버거"),
    ("🥘", "한식"), ("🌮", "양식"), ("🍰", "카페·디저트"), ("🥡", "분식"), ("🌙", "야식"),
]

struct PromoBanner: Identifiable {
    let id = UUID()
    let colors: [Color]
    let small: String
    let title: String
    let emoji: String
}

private let banners: [PromoBanner] = [
    .init(colors: [Color(red: 42/255, green: 193/255, blue: 188/255),
                   Color(red: 26/255, green: 154/255, blue: 149/255)],   // #2AC1BC → #1A9A95
          small: "7월 한정", title: "첫 주문 8,000원 쿠폰팩", emoji: "🎁"),
    .init(colors: [Color(red: 95/255, green: 39/255, blue: 205/255),
                   Color(red: 136/255, green: 84/255, blue: 208/255)],   // #5F27CD → #8854D0
          small: "한집배달", title: "지금은 피크타임 할인 중", emoji: "⚡"),
    .init(colors: [Color(red: 255/255, green: 121/255, blue: 63/255),
                   Color(red: 255/255, green: 177/255, blue: 66/255)],   // #FF793F → #FFB142
          small: "장보기·쇼핑", title: "수박 반통 오늘 도착", emoji: "🍉"),
]

struct ShopCard: Identifiable {
    let id = UUID()
    var img: String?
    let emoji: String
    let fallback: [Color]
    var coupon: String?
    let name: String
    var star: String?
    let info: String
}

private let hotShops: [ShopCard] = [
    .init(img: "https://picsum.photos/id/292/340/220", emoji: "🍗",
          fallback: [Color(red: 255/255, green: 232/255, blue: 214/255), Color(red: 255/255, green: 211/255, blue: 168/255)],
          coupon: "3,000원 쿠폰", name: "교촌 허니콤보 강남점", star: "★ 4.9", info: "(2,841) · 15~25분"),
    .init(img: "https://picsum.photos/id/1060/340/220", emoji: "🍕",
          fallback: [Color(red: 255/255, green: 224/255, blue: 224/255), Color(red: 255/255, green: 201/255, blue: 201/255)],
          name: "피자헤븐 시카고딥디쉬", star: "★ 4.7", info: "(912) · 배달비 무료"),
    .init(img: "https://picsum.photos/id/429/340/220", emoji: "🍣",
          fallback: [Color(red: 224/255, green: 242/255, blue: 254/255), Color(red: 186/255, green: 230/255, blue: 253/255)],
          coupon: "신규 오픈", name: "스시오마카세 도시락", star: "★ 5.0", info: "(188) · 20~30분"),
]

private let martShops: [ShopCard] = [
    .init(emoji: "🧺",
          fallback: [Color(red: 212/255, green: 252/255, blue: 121/255), Color(red: 150/255, green: 230/255, blue: 161/255)],
          name: "장보기 30분 배달", info: "과일·정육·생필품"),
    .init(emoji: "💊",
          fallback: [Color(red: 161/255, green: 196/255, blue: 253/255), Color(red: 194/255, green: 233/255, blue: 251/255)],
          name: "새벽 안전상비약", info: "24시간 · 즉시 배달"),
]

private let tabs: [(icon: String, label: String)] = [
    ("🏠", "홈"), ("🔍", "검색"), ("🧾", "주문내역"), ("❤️", "찜"), ("👤", "마이배민"),
]

// MARK: - 메인 뷰
struct DeliveryHome: View {
    @State private var bi = 0     // 배너 인덱스
    @State private var tab = 0
    private let bannerTimer = Timer.publish(every: 3.2, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            headZone
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    categoryGrid
                    bannerCarousel
                    sectionHead("우리 동네 인기 맛집")
                    shopRow(hotShops)
                    sectionHead("이럴 때 배민 B마트")
                    shopRow(martShops)
                }
                .padding(.bottom, 100)
            }
            .overlay(alignment: .bottom) { orderBar }
            tabbar
        }
        .background(Color.white)
    }

    // MARK: 민트 헤더 (주소 + 검색바)
    private var headZone: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("📍 테헤란로 427 ▼")
                .font(.system(size: 16.5, weight: .black))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.top, 6)
            HStack(spacing: 10) {
                Text("⌕").font(.system(size: 16, weight: .bold)).foregroundStyle(Color.deliveryPrimary)
                Text("오늘 뭐 먹지? 치킨 어때요")
                    .font(.system(size: 14.5)).foregroundStyle(Color.deliverySub)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 14))  // radius.search
            .shadow(color: .black.opacity(0.08), radius: 7, y: 4)
            .padding(.horizontal, 18)
            .padding(.top, 14)
            .padding(.bottom, 18)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.deliveryPrimary)
    }

    // MARK: 카테고리 그리드 (5열 이모지)
    private var categoryGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 5), spacing: 16) {
            ForEach(0..<cats.count, id: \.self) { i in
                Button {} label: {
                    VStack(spacing: 7) {
                        Text(cats[i].emoji)
                            .font(.system(size: 25))
                            .frame(width: 52, height: 52)                               // component.category-icon
                            .background(Color.deliveryCatBG, in: RoundedRectangle(cornerRadius: 18)) // radius.category
                        Text(cats[i].label)
                            .font(.system(size: 11.5))
                            .foregroundStyle(Color(red: 58/255, green: 58/255, blue: 60/255))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 8)
    }

    // MARK: 자동 순환 배너 캐러셀 (TabView .page + Timer 3.2s)
    private var bannerCarousel: some View {
        TabView(selection: $bi) {
            ForEach(0..<banners.count, id: \.self) { i in
                bannerView(banners[i]).tag(i)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 96)                                               // component.banner-height
        .clipShape(RoundedRectangle(cornerRadius: 16))                   // radius.banner
        .overlay(alignment: .bottomTrailing) {
            HStack(spacing: 5) {
                ForEach(0..<banners.count, id: \.self) { i in
                    Circle()
                        .fill(i == bi ? Color.white : Color.white.opacity(0.45))
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.trailing, 12)
            .padding(.bottom, 10)
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .onReceive(bannerTimer) { _ in
            withAnimation(.easeOut(duration: 0.5)) { bi = (bi + 1) % banners.count }
        }
    }

    private func bannerView(_ b: PromoBanner) -> some View {
        ZStack(alignment: .leading) {
            LinearGradient(colors: b.colors, startPoint: .leading, endPoint: .bottomTrailing)
            VStack(alignment: .leading, spacing: 4) {
                Text(b.small).font(.system(size: 12, weight: .medium)).foregroundStyle(.white.opacity(0.9))
                Text(b.title).font(.system(size: 18, weight: .black)).foregroundStyle(.white)
            }
            .padding(.horizontal, 22)
        }
        .overlay(alignment: .bottomTrailing) {
            Text(b.emoji).font(.system(size: 42)).padding(.trailing, 18).padding(.bottom, 4)
        }
    }

    // MARK: 섹션 헤더
    private func sectionHead(_ title: String) -> some View {
        HStack(alignment: .lastTextBaseline) {
            Text(title).font(.system(size: 17, weight: .black)).foregroundStyle(Color.deliveryInk)
            Spacer()
            Text("전체보기 ›").font(.system(size: 12.5)).foregroundStyle(Color.deliverySub)
        }
        .padding(.horizontal, 18)
        .padding(.top, 26)
        .padding(.bottom, 12)
    }

    // MARK: 가로 스크롤 가게 카드 (쿠폰 뱃지 + 별점 + 이모지 폴백)
    private func shopRow(_ shops: [ShopCard]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 12) {
                ForEach(shops) { shop in
                    VStack(alignment: .leading, spacing: 0) {
                        ZStack {
                            LinearGradient(colors: shop.fallback, startPoint: .topLeading, endPoint: .bottomTrailing)
                            Text(shop.emoji).font(.system(size: 40))
                            if let img = shop.img {
                                AsyncImage(url: URL(string: img)) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Color.clear
                                }
                            }
                        }
                        .frame(width: 168, height: 108)                          // component.shop-card-width
                        .clipShape(RoundedRectangle(cornerRadius: 14))           // radius.card
                        .overlay(alignment: .topLeading) {
                            if let coupon = shop.coupon {
                                Text(coupon)
                                    .font(.system(size: 10.5, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3.5)
                                    .background(Color.deliveryInk, in: RoundedRectangle(cornerRadius: 7))
                                    .padding(8)
                            }
                        }
                        Text(shop.name)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.deliveryInk)
                            .padding(.top, 9)
                        HStack(spacing: 3) {
                            if let star = shop.star {
                                Text(star).font(.system(size: 12, weight: .bold)).foregroundStyle(Color.deliveryStar)
                            }
                            Text(shop.info).font(.system(size: 12)).foregroundStyle(Color.deliverySub)
                        }
                        .padding(.top, 3)
                    }
                    .frame(width: 168, alignment: .leading)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: 주문 현황 플로팅 바 (라이브 액티비티)
    private var orderBar: some View {
        HStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(Color.deliveryPrimary)
            VStack(alignment: .leading, spacing: 1) {
                Text("교촌 허니콤보 배달 중")
                    .font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
                Text("라이더가 음식을 픽업했어요")
                    .font(.system(size: 12.5)).foregroundStyle(.white.opacity(0.7))
            }
            Spacer()
            Text("12분").font(.system(size: 15, weight: .black)).foregroundStyle(Color.deliveryPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(Color.deliveryInk, in: RoundedRectangle(cornerRadius: 16))   // radius.order-bar
        .shadow(color: .black.opacity(0.35), radius: 15, y: 14)
        .padding(.horizontal, 14)
        .padding(.bottom, 8)
    }

    // MARK: 탭바 (활성 = 민트)
    private var tabbar: some View {
        HStack {
            ForEach(0..<tabs.count, id: \.self) { i in
                Button { tab = i } label: {
                    VStack(spacing: 3) {
                        Text(tabs[i].icon).font(.system(size: 20)).opacity(tab == i ? 1 : 0.4)
                        Text(tabs[i].label)
                            .font(.system(size: 10.5, weight: tab == i ? .bold : .medium))
                            .foregroundStyle(tab == i ? Color.deliveryPrimary
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
        .overlay(alignment: .top) { Rectangle().fill(Color.deliveryDivider).frame(height: 1) }
    }
}

#Preview {
    DeliveryHome()
}
