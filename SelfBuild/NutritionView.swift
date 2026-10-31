import SwiftUI

struct NutritionView: View {
    @EnvironmentObject var store: AppStore
    private let cols = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView {
                    VStack(spacing: 16) {
                        VStack(spacing: 14) {
                            GaugeBar(title: "Calories", value: store.kcalToday, goal: store.calorieGoal, unit: "kcal")
                            GaugeBar(title: "Protéines", value: store.proteinToday, goal: store.proteinGoal, unit: "g")
                        }
                        .padding(16).glassCard(24)

                        LazyVGrid(columns: cols, spacing: 12) {
                            ForEach(FoodCard.all) { card in
                                Button {
                                    store.addFood(card, grams: card.portion); Haptic.tap()
                                } label: {
                                    VStack(spacing: 6) {
                                        Text(card.emoji).font(.system(size: 40))
                                        Text(card.name).font(.headline).multilineTextAlignment(.center)
                                        Text("+\(Int(card.portion)) g").font(.subheadline.monospacedDigit()).foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity).padding(.vertical, 18).glassCard(24)
                                }
                                .buttonStyle(PressStyle())
                                .contextMenu {
                                    ForEach([50, 100, 150, 200, 300], id: \.self) { g in
                                        Button("+\(g) g") { store.addFood(card, grams: Double(g)) }
                                    }
                                }
                            }
                        }
                        Text("Appui long sur une carte pour une autre portion.").font(.caption).foregroundStyle(.secondary)

                        if !store.todayFoods.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Aujourd'hui").font(.headline)
                                ForEach(store.todayFoods.reversed()) { f in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(f.name); Text("\(Int(f.grams)) g").font(.caption).foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Text("\(Int(f.kcal)) kcal · \(Int(f.protein)) g P").font(.caption.monospacedDigit())
                                        Button { store.removeFood(f) } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary) }
                                    }
                                }
                            }
                            .padding(16).frame(maxWidth: .infinity, alignment: .leading).glassCard(24)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Nutrition")
        }
        .hideKeyboardOnTap()
    }
}
