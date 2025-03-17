//
//  DrinkDetailView.swift
//  Brewbuddy
//
//  Created by 吴炜 on 3/16/25.
//

import SwiftUI

struct DrinkDetailView: View {
    let drink: Drink
    @State private var selectedSize: DrinkSize = .grande
    @State private var animateContent: Bool = false
    @State private var showingNutritionDetails = false
    @State private var addedToFavorites = false
    @Environment(\.dismiss) private var dismiss
    
    // 触觉反馈生成器
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        ZStack {
            // 背景
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // 饮品图片
                    imageSection
                    
                    // 内容区域
                    VStack(alignment: .leading, spacing: 25) {
                        // 饮品名称和描述
                        nameAndDescriptionSection
                        
                        // 杯型选择
                        sizeSelectionSection
                        
                        // 营养信息概览
                        nutritionOverviewSection
                        
                        // 操作按钮
                        actionButtonsSection
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }
            }
            .ignoresSafeArea(edges: .top)
            
            // 关闭按钮
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                            .padding()
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            feedbackGenerator.prepare()
            
            withAnimation(.easeOut(duration: 0.5)) {
                animateContent = true
            }
        }
        .sheet(isPresented: $showingNutritionDetails) {
            nutritionDetailsView
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
    
    // 图片区域
    private var imageSection: some View {
        ZStack(alignment: .bottom) {
            // 饮品图片
            AsyncImage(url: URL(string: drink.imageURL ?? "")) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "cup.and.saucer.fill")
                                .font(.system(size: 70))
                                .foregroundColor(.gray)
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "cup.and.saucer.fill")
                                .font(.system(size: 70))
                                .foregroundColor(.gray)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 350)
            .clipped()
            
            // 渐变遮罩
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.5)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 100)
            
            // 分类标签
            if let category = DrinkCategory(rawValue: drink.category) {
                HStack {
                    Text(category.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(categoryColor(for: category).opacity(0.8))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
        .opacity(animateContent ? 1 : 0)
    }
    
    // 名称和描述区域
    private var nameAndDescriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(drink.name)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(drink.drinkDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }
    
    // 杯型选择区域
    private var sizeSelectionSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("选择杯型")
                .font(.headline)
            
            HStack(spacing: 15) {
                ForEach(DrinkSize.allCases) { size in
                    SizeButton(
                        size: size,
                        isSelected: selectedSize == size,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedSize = size
                                feedbackGenerator.impactOccurred()
                            }
                        }
                    )
                }
            }
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }
    
    // 营养信息概览区域
    private var nutritionOverviewSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("营养信息")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    showingNutritionDetails = true
                    feedbackGenerator.impactOccurred(intensity: 0.7)
                }) {
                    Text("查看详情")
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                }
            }
            
            if let nutrition = drink.nutrition(for: selectedSize) {
                HStack(spacing: 0) {
                    // 卡路里
                    NutritionCircle(
                        value: "\(nutrition.calories)",
                        label: "卡路里",
                        color: .orange,
                        actualValue: Double(nutrition.calories),
                        maxValue: 500
                    )
                    
                    Spacer()
                    
                    // 咖啡因
                    NutritionCircle(
                        value: "\(nutrition.caffeine)",
                        label: "咖啡因 (mg)",
                        color: .blue,
                        actualValue: Double(nutrition.caffeine),
                        maxValue: 300
                    )
                    
                    Spacer()
                    
                    // 糖分
                    NutritionCircle(
                        value: String(format: "%.1f", nutrition.sugar),
                        label: "糖分 (g)",
                        color: .pink,
                        actualValue: Double(nutrition.sugar),
                        maxValue: 50
                    )
                }
            } else {
                Text("暂无营养信息")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }
    
    // 操作按钮区域
    private var actionButtonsSection: some View {
        VStack(spacing: 15) {
            // 收藏按钮
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    addedToFavorites.toggle()
                    feedbackGenerator.impactOccurred()
                }
            }) {
                HStack {
                    Image(systemName: addedToFavorites ? "heart.fill" : "heart")
                        .foregroundColor(addedToFavorites ? .red : .primary)
                    
                    Text(addedToFavorites ? "已收藏" : "收藏")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
            }
            
            // 下单按钮
            Button(action: {
                // 下单逻辑
                feedbackGenerator.impactOccurred(intensity: 0.9)
            }) {
                HStack {
                    Image(systemName: "bag")
                    Text("立即下单")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding(.top, 10)
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }
    
    // 营养详情视图
    private var nutritionDetailsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 标题
            HStack {
                Text("\(drink.name) 的营养信息")
                    .font(.headline)
                
                Spacer()
                
                Text(selectedSize.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.top)
            
            if let nutrition = drink.nutrition(for: selectedSize) {
                // 详细营养信息
                VStack(spacing: 0) {
                    NutritionDetailRow(
                        label: "卡路里",
                        value: "\(nutrition.calories)",
                        color: .orange
                    )
                    
                    Divider()
                    
                    NutritionDetailRow(
                        label: "咖啡因",
                        value: "\(nutrition.caffeine) mg",
                        color: .blue
                    )
                    
                    Divider()
                    
                    NutritionDetailRow(
                        label: "脂肪",
                        value: String(format: "%.1f g", nutrition.fat),
                        color: .yellow
                    )
                    
                    Divider()
                    
                    NutritionDetailRow(
                        label: "糖分",
                        value: String(format: "%.1f g", nutrition.sugar),
                        color: .pink
                    )
                    
                    Divider()
                    
                    NutritionDetailRow(
                        label: "蛋白质",
                        value: String(format: "%.1f g", nutrition.protein),
                        color: .green
                    )
                }
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
            } else {
                Text("暂无营养信息")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
            
            Spacer()
        }
    }
    
    // 根据分类返回对应的颜色
    private func categoryColor(for category: DrinkCategory) -> Color {
        switch category {
        case .coffee:
            return .brown
        case .tea:
            return .green
        case .refreshers:
            return .purple
        case .frappuccino:
            return .pink
        case .coldBrew:
            return .blue
        case .espresso:
            return .orange
        case .hotChocolate:
            return .red
        case .other:
            return .gray
        }
    }
}

// 杯型选择按钮
struct SizeButton: View {
    let size: DrinkSize
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // 杯子图标
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: isSelected ? 30 : 24))
                    .foregroundColor(isSelected ? .accentColor : .secondary)
                    .scaleEffect(getSizeScale())
                
                // 杯型名称
                Text(size.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .primary : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color(UIColor.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // 根据杯型获取图标大小
    private func getSizeScale() -> CGFloat {
        switch size {
        case .tall:
            return 0.8
        case .grande:
            return 1.0
        case .venti:
            return 1.2
        }
    }
}

// 营养信息圆形组件
struct NutritionCircle: View {
    let value: String
    let label: String
    let color: Color
    let maxValue: Double
    let actualValue: Double
    
    init(value: String, label: String, color: Color, actualValue: Double, maxValue: Double = 500) {
        self.value = value
        self.label = label
        self.color = color
        self.actualValue = actualValue
        self.maxValue = maxValue
    }
    
    // 计算圆圈大小比例
    private var sizeRatio: CGFloat {
        let ratio = min(actualValue / maxValue, 1.0)
        // 确保即使是很小的值也有一个最小尺寸
        return max(0.4, ratio)
    }
    
    // 获取咖啡因的持续时间描述
    private var caffeineDescription: String? {
        if label.contains("咖啡因") {
            // 咖啡因在体内的半衰期约为5-6小时
            let hours = (actualValue / 100) * 5
            if hours > 0 {
                return String(format: "约持续%.1f小时", hours)
            }
        }
        return nil
    }
    
    // 获取卡路里的食物对照
    private var caloriesComparison: String? {
        if label.contains("卡路里") {
            // 一根香蕉约100卡路里，一碗米饭约200卡路里
            if actualValue > 300 {
                return String(format: "≈ %.1f碗米饭", actualValue / 200)
            } else {
                return String(format: "≈ %.1f根香蕉", actualValue / 100)
            }
        }
        return nil
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // 背景圆圈
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 80 * sizeRatio, height: 80 * sizeRatio)
                
                // 边框圆圈
                Circle()
                    .stroke(color, lineWidth: 3)
                    .frame(width: 80 * sizeRatio, height: 80 * sizeRatio)
                
                // 数值
                VStack(spacing: 2) {
                    Text(value)
                        .font(.system(size: 16 * sizeRatio))
                        .fontWeight(.bold)
                        .foregroundColor(color)
                }
            }
            .frame(width: 80, height: 80)
            
            // 标签
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            // 对照组信息
            if let comparison = caffeineDescription ?? caloriesComparison {
                Text(comparison)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, -4)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// 营养详情行组件
struct NutritionDetailRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            HStack(spacing: 10) {
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                
                Text(label)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text(value)
                .fontWeight(.semibold)
        }
        .padding()
    }
}

#Preview {
    let nutrition = Nutrition(calories: 250, caffeine: 150, fat: 10, sugar: 23, protein: 13)
    let drink = Drink(
        name: "拿铁",
        description: "醇厚的浓缩咖啡与丝滑的蒸汽牛奶完美融合，口感柔和。",
        imageURL: "https://www.starbucks.com.cn/images/products/latte.jpg",
        category: .coffee,
        nutritionGrande: nutrition
    )
    
    return DrinkDetailView(drink: drink)
} 