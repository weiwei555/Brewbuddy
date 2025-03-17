//
//  Drink.swift
//  Brewbuddy
//
//  Created by 吴炜 on 3/16/25.
//

import Foundation
import SwiftData

// 饮品分类枚举
enum DrinkCategory: String, Codable, CaseIterable, Identifiable {
    case coffee = "咖啡"
    case tea = "茶"
    case refreshers = "清爽饮料"
    case frappuccino = "星冰乐"
    case coldBrew = "冷萃咖啡"
    case espresso = "浓缩咖啡"
    case hotChocolate = "热巧克力"
    case other = "其他"
    
    var id: String { self.rawValue }
}

// 饮品大小枚举
enum DrinkSize: String, Codable, CaseIterable, Identifiable {
    case tall = "中杯(Tall)"
    case grande = "大杯(Grande)"
    case venti = "超大杯(Venti)"
    
    var id: String { self.rawValue }
}

// 饮品心情枚举
enum DrinkMood: String, CaseIterable, Identifiable {
    case energize = "提神醒脑"
    case relax = "放松心情"
    case refresh = "清爽解渴"
    case indulge = "甜蜜享受"
    case warm = "温暖舒适"
    
    var id: String { self.rawValue }
}

// 营养信息模型
@Model
final class Nutrition {
    var calories: Int
    var caffeine: Int // 单位: mg
    var fat: Double // 单位: g
    var sugar: Double // 单位: g
    var protein: Double // 单位: g
    
    init(calories: Int, caffeine: Int, fat: Double, sugar: Double, protein: Double) {
        self.calories = calories
        self.caffeine = caffeine
        self.fat = fat
        self.sugar = sugar
        self.protein = protein
    }
}

// 饮品模型
@Model
final class Drink {
    var name: String
    var drinkDescription: String
    var imageURL: String?
    var category: String
    var isFeatured: Bool
    var isAvailable: Bool
    var nutritionTall: Nutrition?
    var nutritionGrande: Nutrition?
    var nutritionVenti: Nutrition?
    
    init(name: String, description: String, imageURL: String? = nil, category: DrinkCategory, isFeatured: Bool = false, isAvailable: Bool = true, nutritionTall: Nutrition? = nil, nutritionGrande: Nutrition? = nil, nutritionVenti: Nutrition? = nil) {
        self.name = name
        self.drinkDescription = description
        self.imageURL = imageURL
        self.category = category.rawValue
        self.isFeatured = isFeatured
        self.isAvailable = isAvailable
        self.nutritionTall = nutritionTall
        self.nutritionGrande = nutritionGrande
        self.nutritionVenti = nutritionVenti
    }
    
    // 获取指定杯型的营养信息
    func nutrition(for size: DrinkSize) -> Nutrition? {
        switch size {
        case .tall:
            return nutritionTall
        case .grande:
            return nutritionGrande
        case .venti:
            return nutritionVenti
        }
    }
}
