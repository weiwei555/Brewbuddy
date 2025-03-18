//
//  FavoritesView.swift
//  Brewbuddy
//
//  Created by 吴炜 on 3/17/25.
//

import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var drinks: [Drink]
    @ObservedObject var viewModel: DrinkViewModel
    @Environment(\.dismiss) private var dismiss
    
    // 触觉反馈生成器
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    // 选中的营养信息类型
    @State private var selectedNutritionType: NutritionType = .calories
    
    // 营养信息类型枚举
    enum NutritionType: String, CaseIterable, Identifiable {
        case calories = "卡路里"
        case caffeine = "咖啡因"
        case sugar = "糖分"
        case fat = "脂肪"
        case protein = "蛋白质"
        
        var id: String { self.rawValue }
        
        var systemImage: String {
            switch self {
            case .calories: return "flame.fill"
            case .caffeine: return "bolt.fill"
            case .sugar: return "drop.fill"
            case .fat: return "circle.hexagongrid.fill"
            case .protein: return "figure.strengthtraining.traditional"
            }
        }
        
        var color: Color {
            switch self {
            case .calories: return .orange
            case .caffeine: return .blue
            case .sugar: return .pink
            case .fat: return .yellow
            case .protein: return .green
            }
        }
        
        var unit: String {
            switch self {
            case .calories: return ""
            case .caffeine: return "mg"
            case .sugar: return "g"
            case .fat: return "g"
            case .protein: return "g"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景 - 米黄色到白色的温柔渐变
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.98, green: 0.95, blue: 0.9), // 米黄色
                        Color.white
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // 主内容
                VStack(spacing: 0) {
                    // 营养信息类型选择器
                    nutritionTypeSelector
                        .padding(.top, 16)
                    
                    // 收藏的饮品列表
                    ScrollView {
                        let favoriteDrinks = viewModel.getFavoriteDrinks(from: drinks)
                        
                        if favoriteDrinks.isEmpty {
                            // 无收藏状态
                            emptyStateView
                        } else {
                            // 收藏饮品对比视图
                            comparisonView(drinks: favoriteDrinks)
                        }
                    }
                    .padding(.top, 16)
                }
                .padding(.horizontal)
            }
            .navigationTitle("我的收藏")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                feedbackGenerator.prepare()
            }
        }
    }
    
    // 营养信息类型选择器
    private var nutritionTypeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(NutritionType.allCases) { type in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedNutritionType = type
                            feedbackGenerator.impactOccurred(intensity: 0.7)
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: type.systemImage)
                                .font(.system(size: 12))
                            
                            Text(type.rawValue)
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectedNutritionType == type ? type.color : Color.gray.opacity(0.1))
                        )
                        .foregroundColor(selectedNutritionType == type ? .white : Color.primary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    // 空状态视图
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(Color.brown.opacity(0.5))
            
            Text("您还没有收藏任何饮品")
                .font(.headline)
                .foregroundColor(Color.brown)
            
            Text("浏览饮品并点击收藏按钮，将它们添加到这里进行对比")
                .font(.subheadline)
                .foregroundColor(Color.brown.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                dismiss()
            }) {
                Text("浏览饮品")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.brown)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .padding()
    }
    
    // 收藏饮品对比视图
    private func comparisonView(drinks: [Drink]) -> some View {
        VStack(spacing: 25) {
            // 营养信息对比图表
            nutritionComparisonChart(drinks: drinks)
            
            // 饮品详细信息列表
            favoritesList(drinks: drinks)
        }
        .padding(.bottom, 20)
    }
    
    // 营养信息对比图表
    private func nutritionComparisonChart(drinks: [Drink]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("营养信息对比")
                .font(.headline)
                .foregroundColor(Color.brown)
            
            // 图表标题和说明
            HStack {
                Image(systemName: selectedNutritionType.systemImage)
                    .foregroundColor(selectedNutritionType.color)
                
                Text("\(selectedNutritionType.rawValue)对比")
                    .font(.subheadline)
                    .foregroundColor(Color.brown)
                
                Spacer()
                
                Text("基于大杯(Grande)规格")
                    .font(.caption)
                    .foregroundColor(Color.gray)
            }
            
            // 图表
            VStack(spacing: 12) {
                ForEach(drinks) { drink in
                    if let nutrition = drink.nutritionGrande {
                        let value = nutritionValue(for: selectedNutritionType, from: nutrition)
                        let maxValue = maxNutritionValue(for: selectedNutritionType, in: drinks)
                        
                        HStack(spacing: 12) {
                            // 饮品名称
                            Text(drink.name)
                                .font(.subheadline)
                                .foregroundColor(Color.brown)
                                .frame(width: 80, alignment: .leading)
                                .lineLimit(1)
                            
                            // 进度条
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    // 背景
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.gray.opacity(0.1))
                                        .frame(height: 20)
                                    
                                    // 进度
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(selectedNutritionType.color)
                                        .frame(width: maxValue > 0 ? CGFloat(value / maxValue) * geometry.size.width : 0, height: 20)
                                }
                            }
                            .frame(height: 20)
                            
                            // 数值
                            Text("\(formatValue(value))\(selectedNutritionType.unit)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(selectedNutritionType.color)
                                .frame(width: 60, alignment: .trailing)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    // 收藏饮品列表
    private func favoritesList(drinks: [Drink]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("收藏的饮品")
                .font(.headline)
                .foregroundColor(Color.brown)
            
            ForEach(drinks) { drink in
                FavoriteCard(drink: drink, viewModel: viewModel)
            }
        }
    }
    
    // 获取指定类型的营养信息值
    private func nutritionValue(for type: NutritionType, from nutrition: Nutrition) -> Double {
        switch type {
        case .calories:
            return Double(nutrition.calories)
        case .caffeine:
            return Double(nutrition.caffeine)
        case .sugar:
            return nutrition.sugar
        case .fat:
            return nutrition.fat
        case .protein:
            return nutrition.protein
        }
    }
    
    // 获取指定类型的最大营养信息值
    private func maxNutritionValue(for type: NutritionType, in drinks: [Drink]) -> Double {
        let values = drinks.compactMap { drink -> Double? in
            guard let nutrition = drink.nutritionGrande else { return nil }
            return nutritionValue(for: type, from: nutrition)
        }
        
        return values.max() ?? 1.0
    }
    
    // 格式化数值
    private func formatValue(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(value))"
        } else {
            return String(format: "%.1f", value)
        }
    }
}

// 收藏饮品卡片
struct FavoriteCard: View {
    let drink: Drink
    @ObservedObject var viewModel: DrinkViewModel
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            HStack(spacing: 12) {
                // 饮品图片
                AsyncImage(url: URL(string: drink.imageURL ?? "")) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                            .overlay(
                                Image(systemName: "cup.and.saucer.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color.brown.opacity(0.3))
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Rectangle()
                            .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                            .overlay(
                                Image(systemName: "cup.and.saucer.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color.brown.opacity(0.3))
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // 饮品名称和营养信息
                VStack(alignment: .leading, spacing: 4) {
                    Text(drink.name)
                        .font(.headline)
                        .foregroundColor(Color.brown)
                        .lineLimit(1)
                    
                    // 营养信息圆圈
                    if let nutrition = drink.nutritionGrande {
                        HStack(spacing: 8) {
                            // 卡路里
                            Label(
                                title: { Text("\(nutrition.calories)").font(.caption).foregroundColor(.orange) },
                                icon: { Image(systemName: "flame.fill").font(.system(size: 10)).foregroundColor(.orange) }
                            )
                            
                            // 咖啡因
                            Label(
                                title: { Text("\(nutrition.caffeine)mg").font(.caption).foregroundColor(.blue) },
                                icon: { Image(systemName: "bolt.fill").font(.system(size: 10)).foregroundColor(.blue) }
                            )
                            
                            // 糖分
                            Label(
                                title: { Text(String(format: "%.1fg", nutrition.sugar)).font(.caption).foregroundColor(.pink) },
                                icon: { Image(systemName: "drop.fill").font(.system(size: 10)).foregroundColor(.pink) }
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // 移除按钮
                Button(action: {
                    withAnimation {
                        viewModel.toggleFavorite(drink: drink)
                    }
                }) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .padding(8)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            NavigationStack {
                DrinkDetailView(drink: drink, viewModel: viewModel)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("关闭") {
                                showingDetail = false
                            }
                        }
                    }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }
}

// 小型营养信息圆圈 - 不再使用
struct NutritionCircleSmall: View {
    let value: String
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.1))
                .frame(width: 36, height: 36)
            
            Circle()
                .stroke(color, lineWidth: 2)
                .frame(width: 36, height: 36)
            
            Text(value)
                .font(.system(size: 10))
                .fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}

#Preview {
    let viewModel = DrinkViewModel()
    return FavoritesView(viewModel: viewModel)
        .modelContainer(for: Drink.self, inMemory: true)
} 