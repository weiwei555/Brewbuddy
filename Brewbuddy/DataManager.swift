//
//  DataManager.swift
//  Brewbuddy
//
//  Created by 吴炜 on 3/16/25.
//

import Foundation
import SwiftData

class DataManager {
    
    // 从 JSON 文件加载数据并预加载到数据库
    static func preloadSampleData(modelContext: ModelContext) {
        // 尝试从 JSON 文件加载数据
        if let drinks = loadDrinksFromJSON() {
            // 将加载的数据添加到数据库
            for drink in drinks {
                modelContext.insert(drink)
            }
            print("成功从 JSON 文件加载了 \(drinks.count) 个饮品")
        } else {
            // 如果 JSON 加载失败，使用硬编码的示例数据
            let sampleDrinks = createSampleDrinks()
            for drink in sampleDrinks {
                modelContext.insert(drink)
            }
            print("使用硬编码的示例数据，加载了 \(sampleDrinks.count) 个饮品")
        }
        
        do {
            try modelContext.save()
            print("数据保存成功")
        } catch {
            print("保存数据时出错: \(error)")
        }
    }
    
    // 从 JSON 文件加载饮品数据
    private static func loadDrinksFromJSON() -> [Drink]? {
        guard let url = Bundle.main.url(forResource: "drinks", withExtension: "json") else {
            print("未找到 drinks.json 文件")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let drinkData = try decoder.decode([DrinkData].self, from: data)
            
            // 将 DrinkData 转换为 Drink 模型
            return drinkData.map { drinkData in
                let nutritionTall = drinkData.nutritionTall != nil ? 
                    Nutrition(
                        calories: drinkData.nutritionTall!.calories,
                        caffeine: drinkData.nutritionTall!.caffeine,
                        fat: drinkData.nutritionTall!.fat,
                        sugar: drinkData.nutritionTall!.sugar,
                        protein: drinkData.nutritionTall!.protein
                    ) : nil
                
                let nutritionGrande = drinkData.nutritionGrande != nil ? 
                    Nutrition(
                        calories: drinkData.nutritionGrande!.calories,
                        caffeine: drinkData.nutritionGrande!.caffeine,
                        fat: drinkData.nutritionGrande!.fat,
                        sugar: drinkData.nutritionGrande!.sugar,
                        protein: drinkData.nutritionGrande!.protein
                    ) : nil
                
                let nutritionVenti = drinkData.nutritionVenti != nil ? 
                    Nutrition(
                        calories: drinkData.nutritionVenti!.calories,
                        caffeine: drinkData.nutritionVenti!.caffeine,
                        fat: drinkData.nutritionVenti!.fat,
                        sugar: drinkData.nutritionVenti!.sugar,
                        protein: drinkData.nutritionVenti!.protein
                    ) : nil
                
                let category = DrinkCategory(rawValue: drinkData.category) ?? .other
                
                return Drink(
                    name: drinkData.name,
                    description: drinkData.description,
                    imageURL: drinkData.imageURL,
                    category: category,
                    isFeatured: drinkData.isFeatured ?? false,
                    isAvailable: true,
                    nutritionTall: nutritionTall,
                    nutritionGrande: nutritionGrande,
                    nutritionVenti: nutritionVenti
                )
            }
        } catch {
            print("解析 JSON 文件时出错: \(error)")
            return nil
        }
    }
    
    // 创建示例饮品数据（作为备用）
    private static func createSampleDrinks() -> [Drink] {
        var drinks: [Drink] = []
        
        // 咖啡类
        let latteTall = Nutrition(calories: 190, caffeine: 75, fat: 7, sugar: 18, protein: 10)
        let latteGrande = Nutrition(calories: 250, caffeine: 150, fat: 10, sugar: 23, protein: 13)
        let latteVenti = Nutrition(calories: 340, caffeine: 225, fat: 14, sugar: 31, protein: 17)
        
        let latte = Drink(
            name: "拿铁",
            description: "醇厚的浓缩咖啡与丝滑的蒸汽牛奶完美融合，口感柔和。",
            imageURL: "https://www.starbucks.com.cn/images/products/latte.jpg",
            category: .coffee,
            isFeatured: true,
            nutritionTall: latteTall,
            nutritionGrande: latteGrande,
            nutritionVenti: latteVenti
        )
        drinks.append(latte)
        
        let americanoTall = Nutrition(calories: 15, caffeine: 150, fat: 0, sugar: 0, protein: 1)
        let americanoGrande = Nutrition(calories: 20, caffeine: 225, fat: 0, sugar: 0, protein: 1)
        let americanoVenti = Nutrition(calories: 25, caffeine: 300, fat: 0, sugar: 0, protein: 1)
        
        let americano = Drink(
            name: "美式咖啡",
            description: "浓缩咖啡与热水的经典混合，带来醇厚的咖啡风味。",
            imageURL: "https://www.starbucks.com.cn/images/products/caffe-americano.jpg",
            category: .coffee,
            nutritionTall: americanoTall,
            nutritionGrande: americanoGrande,
            nutritionVenti: americanoVenti
        )
        drinks.append(americano)
        
        // 冷萃咖啡
        let coldBrewTall = Nutrition(calories: 5, caffeine: 155, fat: 0, sugar: 0, protein: 0)
        let coldBrewGrande = Nutrition(calories: 5, caffeine: 205, fat: 0, sugar: 0, protein: 0)
        let coldBrewVenti = Nutrition(calories: 10, caffeine: 310, fat: 0, sugar: 0, protein: 0)
        
        let coldBrew = Drink(
            name: "冷萃咖啡",
            description: "精选咖啡豆经过20小时慢萃，带来顺滑口感与天鹅绒般的质地。",
            imageURL: "https://www.starbucks.com.cn/images/products/cold-brew.jpg",
            category: .coldBrew,
            isFeatured: true,
            nutritionTall: coldBrewTall,
            nutritionGrande: coldBrewGrande,
            nutritionVenti: coldBrewVenti
        )
        drinks.append(coldBrew)
        
        // 星冰乐
        let mochaFrappuccinoTall = Nutrition(calories: 290, caffeine: 65, fat: 11, sugar: 40, protein: 4)
        let mochaFrappuccinoGrande = Nutrition(calories: 400, caffeine: 95, fat: 15, sugar: 55, protein: 5)
        let mochaFrappuccinoVenti = Nutrition(calories: 520, caffeine: 130, fat: 19, sugar: 73, protein: 7)
        
        let mochaFrappuccino = Drink(
            name: "摩卡星冰乐",
            description: "咖啡、牛奶与冰块融合，加入摩卡酱与鲜奶油，口感丰富。",
            imageURL: "https://www.starbucks.com.cn/images/products/mocha-frappuccino.jpg",
            category: .frappuccino,
            nutritionTall: mochaFrappuccinoTall,
            nutritionGrande: mochaFrappuccinoGrande,
            nutritionVenti: mochaFrappuccinoVenti
        )
        drinks.append(mochaFrappuccino)
        
        // 茶类
        let greenTeaLatteTall = Nutrition(calories: 240, caffeine: 55, fat: 7, sugar: 31, protein: 9)
        let greenTeaLatteGrande = Nutrition(calories: 320, caffeine: 80, fat: 9, sugar: 41, protein: 12)
        let greenTeaLatteVenti = Nutrition(calories: 430, caffeine: 110, fat: 12, sugar: 55, protein: 16)
        
        let greenTeaLatte = Drink(
            name: "抹茶拿铁",
            description: "优质抹茶粉与蒸汽牛奶的完美结合，带来独特的抹茶风味。",
            imageURL: "https://www.starbucks.com.cn/images/products/green-tea-latte.jpg",
            category: .tea,
            nutritionTall: greenTeaLatteTall,
            nutritionGrande: greenTeaLatteGrande,
            nutritionVenti: greenTeaLatteVenti
        )
        drinks.append(greenTeaLatte)
        
        // 清爽饮料
        let strawberryAcaiTall = Nutrition(calories: 90, caffeine: 20, fat: 0, sugar: 20, protein: 0)
        let strawberryAcaiGrande = Nutrition(calories: 130, caffeine: 30, fat: 0, sugar: 29, protein: 0)
        let strawberryAcaiVenti = Nutrition(calories: 170, caffeine: 40, fat: 0, sugar: 38, protein: 0)
        
        let strawberryAcai = Drink(
            name: "草莓星冰乐",
            description: "草莓果汁与冰块混合，加入真实草莓果粒，清爽怡人。",
            imageURL: "https://www.starbucks.com.cn/images/products/strawberry-acai.jpg",
            category: .refreshers,
            nutritionTall: strawberryAcaiTall,
            nutritionGrande: strawberryAcaiGrande,
            nutritionVenti: strawberryAcaiVenti
        )
        drinks.append(strawberryAcai)
        
        // 浓缩咖啡
        let espressoTall = Nutrition(calories: 10, caffeine: 75, fat: 0, sugar: 0, protein: 0)
        let espressoGrande = Nutrition(calories: 15, caffeine: 150, fat: 0, sugar: 0, protein: 1)
        let espressoVenti = Nutrition(calories: 20, caffeine: 225, fat: 0, sugar: 0, protein: 1)
        
        let espresso = Drink(
            name: "浓缩咖啡",
            description: "精心萃取的浓缩咖啡，浓郁醇厚，是多种咖啡饮品的基础。",
            imageURL: "https://www.starbucks.com.cn/images/products/espresso.jpg",
            category: .espresso,
            nutritionTall: espressoTall,
            nutritionGrande: espressoGrande,
            nutritionVenti: espressoVenti
        )
        drinks.append(espresso)
        
        return drinks
    }
}

// JSON 解析用的数据结构
struct DrinkData: Codable {
    let name: String
    let description: String
    let imageURL: String?
    let category: String
    let isFeatured: Bool?
    let nutritionTall: NutritionData?
    let nutritionGrande: NutritionData?
    let nutritionVenti: NutritionData?
}

struct NutritionData: Codable {
    let calories: Int
    let caffeine: Int
    let fat: Double
    let sugar: Double
    let protein: Double
} 