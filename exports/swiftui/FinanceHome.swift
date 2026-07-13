// Copyright (c) 2026 hyunaeee · MIT License — see /LICENSE at the project root.
//
//  FinanceHome.swift — 금융 홈 · 토스 스타일 (SwiftUI, iOS 17)
//  용도: 자산 리스트(탭 → 바텀시트), 주간 소비 바 차트, 주식 리스트, 5탭 탭바
//  사용법: Xcode 프로젝트에 새 Swift 파일로 그대로 붙여넣기 → 캔버스 #Preview 즉시 동작
//  토큰: exports/tokens/finance.tokens.json 과 1:1 대응 (extension Color)
//

import SwiftUI

// MARK: - 디자인 토큰 (finance.tokens.json)
extension Color {
    static let financePrimary  = Color(red: 49/255,  green: 130/255, blue: 246/255) // #3182F6 — 브랜드 블루
    static let financeBG       = Color(red: 242/255, green: 244/255, blue: 246/255) // #F2F4F6
    static let financeInk      = Color(red: 25/255,  green: 31/255,  blue: 40/255)  // #191F28
    static let financeSub      = Color(red: 139/255, green: 149/255, blue: 161/255) // #8B95A1
    static let financeNegative = Color(red: 240/255, green: 68/255,  blue: 82/255)  // #F04452 — 상승(국내 관례)
    static let financeTrack    = Color(red: 229/255, green: 232/255, blue: 235/255) // #E5E8EB
}

// MARK: - 데이터
struct FinanceAccount: Identifiable {
    let id = UUID()
    let icon: String
    let iconBG: Color
    let name: String
    let amount: String   // "2,483,000"
}

struct FinanceStock: Identifiable {
    let id = UUID()
    let logo: String
    let logoBG: Color
    let name: String
    let price: String
    let delta: String
    let up: Bool
}

private let accounts: [FinanceAccount] = [
    .init(icon: "🏦", iconBG: Color(red: 232/255, green: 243/255, blue: 255/255), name: "토스뱅크 통장", amount: "2,483,000"),
    .init(icon: "🐷", iconBG: Color(red: 255/255, green: 243/255, blue: 224/255), name: "비상금 저금통", amount: "518,200"),
    .init(icon: "📈", iconBG: Color(red: 238/255, green: 244/255, blue: 255/255), name: "증권 계좌", amount: "7,214,850"),
]

private let spendWeek: [(day: String, pct: CGFloat, hot: Bool)] = [
    ("월", 0.38, false), ("화", 0.62, false), ("수", 0.30, false), ("목", 0.88, true),
    ("금", 0.46, false), ("토", 0.20, false), ("일", 0.12, false),
]

private let stocks: [FinanceStock] = [
    .init(logo: "A", logoBG: Color(red: 26/255, green: 26/255, blue: 26/255), name: "애플", price: "312,400원", delta: "+2.4%", up: true),
    .init(logo: "N", logoBG: .financePrimary, name: "엔비디아", price: "198,750원", delta: "+5.1%", up: true),
    .init(logo: "네", logoBG: Color(red: 3/255, green: 199/255, blue: 90/255), name: "네이버", price: "224,000원", delta: "-0.8%", up: false),
]

private let tabs: [(icon: String, label: String)] = [
    ("🏠", "홈"), ("🎁", "혜택"), ("💸", "토스페이"), ("📊", "증권"), ("☰", "전체"),
]

// MARK: - 메인 뷰
struct FinanceHome: View {
    @State private var sheetAccount: FinanceAccount?   // 선택된 계좌 → 바텀시트
    @State private var tab = 0
    @State private var barsAppeared = false

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    assetsCard
                    spendCard
                    stocksCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 6)
                .padding(.bottom, 24)
            }
            tabbar
        }
        .background(Color.financeBG)
        // 계좌 탭 → 바텀시트 (원본 .sheet-open 재현)
        .sheet(item: $sheetAccount) { acct in
            accountSheet(acct)
                .presentationDetents([.height(230)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)   // radius.sheet
        }
    }

    // MARK: 헤더
    private var header: some View {
        HStack {
            Text("toss")
                .font(.system(size: 21, weight: .black))
                .foregroundStyle(Color.financePrimary)
            Spacer()
            Text("💬").font(.system(size: 18))
            Text("🔔").font(.system(size: 18))
                .overlay(alignment: .topTrailing) {
                    Circle().fill(Color.financeNegative)
                        .frame(width: 7, height: 7)
                        .offset(x: 2)
                }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }

    // MARK: 자산 카드
    private var assetsCard: some View {
        card {
            sectionTitle("자산", action: "순서 편집")
            ForEach(accounts) { acct in
                Button { sheetAccount = acct } label: {
                    HStack(spacing: 12) {
                        Text(acct.icon)
                            .font(.system(size: 18))
                            .frame(width: 40, height: 40)
                            .background(acct.iconBG, in: RoundedRectangle(cornerRadius: 14))
                        VStack(alignment: .leading, spacing: 1) {
                            Text(acct.name).font(.system(size: 13)).foregroundStyle(Color.financeSub)
                            Text("\(acct.amount)원")
                                .font(.system(size: 16.5, weight: .bold))
                                .foregroundStyle(Color.financeInk)
                        }
                        Spacer()
                        Text("›").font(.system(size: 16))
                            .foregroundStyle(Color(red: 209/255, green: 214/255, blue: 219/255))
                    }
                    .padding(.vertical, 13)
                    .padding(.horizontal, 4)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            Button {} label: {
                Text("송금하기")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.financePrimary, in: RoundedRectangle(cornerRadius: 14)) // radius.button
            }
            .padding(.top, 10)
        }
    }

    // MARK: 주간 소비 카드 (바 차트 grow 애니메이션)
    private var spendCard: some View {
        card {
            sectionTitle("이번 주 소비", action: "7월 6일 ~ 오늘")
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("184,300원").font(.system(size: 24, weight: .black)).foregroundStyle(Color.financeInk)
                Text("지난주보다 12% ↓")
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundStyle(Color.financeNegative)
            }
            .padding(.top, 6)
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(spendWeek.enumerated()), id: \.offset) { _, bar in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 7)
                            .fill(bar.hot ? Color.financePrimary : Color.financeTrack)
                            .frame(height: barsAppeared ? 74 * bar.pct : 0)
                            .frame(height: 74, alignment: .bottom)
                        Text(bar.day).font(.system(size: 10.5)).foregroundStyle(Color.financeSub)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 16)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) { barsAppeared = true }
            }
        }
    }

    // MARK: 주식 카드 (상승=빨강, 하락=파랑)
    private var stocksCard: some View {
        card {
            sectionTitle("내 주식", action: "실시간")
            ForEach(stocks) { st in
                HStack(spacing: 12) {
                    Text(st.logo)
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(st.logoBG, in: Circle())
                    Text(st.name).font(.system(size: 14.5)).foregroundStyle(Color.financeInk)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 1) {
                        Text(st.price).font(.system(size: 14.5, weight: .bold)).foregroundStyle(Color.financeInk)
                        Text(st.delta)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(st.up ? Color.financeNegative : Color.financePrimary)
                    }
                }
                .padding(.vertical, 11)
                .padding(.horizontal, 4)
            }
        }
    }

    // MARK: 탭바 (5탭 상태 전환)
    private var tabbar: some View {
        HStack {
            ForEach(0..<tabs.count, id: \.self) { i in
                Button { tab = i } label: {
                    VStack(spacing: 3) {
                        Text(tabs[i].icon)
                            .font(.system(size: 21))
                            .opacity(tab == i ? 1 : 0.4)
                        Text(tabs[i].label)
                            .font(.system(size: 10.5, weight: tab == i ? .bold : .medium))
                            .foregroundStyle(tab == i ? Color.financeInk
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
        .overlay(alignment: .top) {
            Rectangle().fill(Color(red: 238/255, green: 240/255, blue: 243/255)).frame(height: 1)
        }
    }

    // MARK: 바텀시트 내용
    private func accountSheet(_ acct: FinanceAccount) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(acct.name)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(Color.financeInk)
            (Text("잔액 ") + Text(acct.amount).bold() + Text("원"))
                .font(.system(size: 13.5))
                .foregroundStyle(Color.financeSub)
                .padding(.top, 6)
            HStack(spacing: 10) {
                Button { sheetAccount = nil } label: {
                    Text("내역 보기")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.financeInk)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color.financeBG, in: RoundedRectangle(cornerRadius: 14))
                }
                Button { sheetAccount = nil } label: {
                    Text("송금")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color.financePrimary, in: RoundedRectangle(cornerRadius: 14))
                }
            }
            .buttonStyle(.plain)
            .padding(.top, 20)
            Spacer()
        }
        .padding(.horizontal, 22)
        .padding(.top, 24)
    }

    // MARK: 공용 조각
    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0, content: content)
            .padding(.horizontal, 18)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 20)) // radius.card
    }

    private func sectionTitle(_ title: String, action: String) -> some View {
        HStack {
            Text(title).font(.system(size: 15, weight: .bold)).foregroundStyle(Color.financeInk)
            Spacer()
            Text(action).font(.system(size: 12.5)).foregroundStyle(Color.financeSub)
        }
    }
}

#Preview {
    FinanceHome()
}
