//
//  DrinkViewModel.swift
//  Brewbuddy
//
//  Created by 吴炜 on 3/16/25.
//

import Foundation
import SwiftUI
import SwiftData
import Combine

class DrinkViewModel: ObservableObject {
    // 筛选条件
    @Published var selectedCategories: Set<DrinkCategory> = Set(DrinkCategory.allCases)
    @Published var caloriesThreshold: Double = 500
    @Published var caffeineThreshold: Double = 300
    @Published var searchText: String = ""
    @Published var selectedSize: DrinkSize = .grande
    
    // 获取筛选后的饮品列表
    func filteredDrinks(drinks: [Drink]) -> [Drink] {
        return drinks.filter { drink in
            // 类别筛选
            guard let category = DrinkCategory(rawValue: drink.category),
                  selectedCategories.contains(category) else {
                return false
            }
            
            // 卡路里和咖啡因筛选
            let nutrition = drink.nutrition(for: selectedSize)
            if let nutrition = nutrition {
                if Double(nutrition.calories) > caloriesThreshold {
                    return false
                }
                
                if Double(nutrition.caffeine) > caffeineThreshold {
                    return false
                }
            }
            
            // 搜索文本筛选
            if !searchText.isEmpty {
                return drink.name.localizedCaseInsensitiveContains(searchText) ||
                       drink.drinkDescription.localizedCaseInsensitiveContains(searchText)
            }
            
            return true
        }
    }
    
    // 根据心情应用筛选条件
    func applyMoodFilter(_ mood: DrinkMood) {
        switch mood {
        case .energize:
            // 提神醒脑 - 高咖啡因饮品
            selectedCategories = [.coffee, .espresso, .coldBrew]
            caffeineThreshold = 500
            caloriesThreshold = 500
            selectedSize = .grande
            
        case .relax:
            // 放松心情 - 低咖啡因饮品，如茶类
            selectedCategories = [.tea, .refreshers]
            caffeineThreshold = 100
            caloriesThreshold = 500
            selectedSize = .grande
            
        case .refresh:
            // 清爽解渴 - 冷饮和低卡路里饮品
            selectedCategories = [.refreshers, .coldBrew, .frappuccino]
            caffeineThreshold = 500
            caloriesThreshold = 300
            selectedSize = .grande
            
        case .indulge:
            // 甜蜜享受 - 甜饮品，不关心卡路里
            selectedCategories = [.frappuccino, .hotChocolate]
            caffeineThreshold = 500
            caloriesThreshold = 600
            selectedSize = .grande
            
        case .warm:
            // 温暖舒适 - 热饮
            selectedCategories = [.coffee, .tea, .hotChocolate, .espresso]
            caffeineThreshold = 500
            caloriesThreshold = 500
            selectedSize = .grande
        }
    }
    
    // 重置所有筛选条件
    func resetFilters() {
        selectedCategories = Set(DrinkCategory.allCases)
        caloriesThreshold = 500
        caffeineThreshold = 300
        searchText = ""
        selectedSize = .grande
    }
    
    // 切换类别选择状态
    func toggleCategory(_ category: DrinkCategory) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }
    
    // 获取所有饮品的平均卡路里
    func averageCalories(drinks: [Drink]) -> Double {
        let validDrinks = drinks.compactMap { $0.nutrition(for: selectedSize) }
        guard !validDrinks.isEmpty else { return 0 }
        
        let totalCalories = validDrinks.reduce(0) { $0 + Double($1.calories) }
        return totalCalories / Double(validDrinks.count)
    }
    
    // 获取所有饮品的平均咖啡因含量
    func averageCaffeine(drinks: [Drink]) -> Double {
        let validDrinks = drinks.compactMap { $0.nutrition(for: selectedSize) }
        guard !validDrinks.isEmpty else { return 0 }
        
        let totalCaffeine = validDrinks.reduce(0) { $0 + Double($1.caffeine) }
        return totalCaffeine / Double(validDrinks.count)
    }
} 