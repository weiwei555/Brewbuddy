//
//  DrinkCard.swift
//  Brewbuddy
//
//  Created by 吴炜 on 3/16/25.
//

import SwiftUI

struct DrinkCard: View {
    let drink: Drink
    
    @State private var isPressed: Bool = false
    @State private var isHovered: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 饮品图片
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: URL(string: drink.imageURL ?? "")) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .foregroundColor(Color(red: 0.95, green: 0.95, blue: 0.95))
                            .overlay(
                                Image(systemName: "cup.and.saucer.fill")
                                    .font(.system(size: 30))
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
                                    .font(.system(size: 30))
                                    .foregroundColor(Color.brown.opacity(0.3))
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // 分类标签 - 移到图片上
                if let category = DrinkCategory(rawValue: drink.category) {
                    Text(category.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.9))
                        )
                        .foregroundColor(categoryColor(for: category))
                        .padding(8)
                }
            }
            
            // 饮品名称
            Text(drink.name)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color.brown)
            
            // 饮品描述
            Text(drink.drinkDescription)
                .font(.subheadline)
                .foregroundColor(Color.brown.opacity(0.7))
                .lineLimit(2)
            
            // 营养信息 - 固定使用 Grande 杯型
            if let nutrition = drink.nutritionGrande {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 16) {
                        NutritionBadge(
                            value: "\(nutrition.calories)",
                            label: "卡路里",
                            systemImage: "flame.fill",
                            color: .orange,
                            backgroundColor: Color.orange.opacity(0.1)
                        )
                        
                        NutritionBadge(
                            value: "\(nutrition.caffeine)mg",
                            label: "咖啡因",
                            systemImage: "bolt.fill",
                            color: .blue,
                            backgroundColor: Color.blue.opacity(0.1)
                        )
                    }
                    
                    // 添加说明文字
                    Text("基于大杯(Grande)规格")
                        .font(.caption2)
                        .foregroundColor(Color.gray)
                        .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.brown.opacity(isHovered ? 0.2 : 0.05), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        // 使用条件编译，只在 macOS 上使用 onHover
        #if os(macOS)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        #endif
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

// 营养信息徽章组件
struct NutritionBadge: View {
    let value: String
    let label: String
    let systemImage: String
    let color: Color
    let backgroundColor: Color
    
    init(value: String, label: String, systemImage: String, color: Color, backgroundColor: Color = Color.gray.opacity(0.1)) {
        self.value = value
        self.label = label
        self.systemImage = systemImage
        self.color = color
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.system(size: 12))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(label)
                    .font(.caption2)
                    .foregroundColor(Color.brown.opacity(0.7))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
        )
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
    
    return DrinkCard(drink: drink)
        .frame(width: 300)
        .padding()
        .background(Color(red: 0.98, green: 0.95, blue: 0.9))
} 