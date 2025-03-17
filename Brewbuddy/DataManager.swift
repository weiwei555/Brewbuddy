//
//  DataManager.swift
//  Brewbuddy
//
//  Created by 吴炜 on 3/16/25.
//

import Foundation
import SwiftData

class DataManager {
    static func preloadSampleData(modelContext: ModelContext) {
        // 检查是否已经有数据
        let descriptor = FetchDescriptor<Drink>()
        
        do {
            let existingDrinks = try modelContext.fetch(descriptor)
            if !existingDrinks.isEmpty {
                print("数据已存在，跳过预加载")
                return
            }
        } catch {
            print("检查现有数据时出错: \(error)")
        }
        
        // 创建示例数据
        let drinks = createSampleDrinks()
        
        // 保存到数据库
        for drink in drinks {
            modelContext.insert(drink)
        }
        
        print("成功预加载 \(drinks.count) 个饮品")
    }
    
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
            description: "精心萃取的浓缩咖啡，浓郁的风味与醇厚的口感。",
            imageURL: "https://www.starbucks.com.cn/images/products/espresso.jpg",
            category: .espresso,
            nutritionTall: espressoTall,
            nutritionGrande: espressoGrande,
            nutritionVenti: espressoVenti
        )
        drinks.append(espresso)
        
        // 热巧克力
        let hotChocolateTall = Nutrition(calories: 320, caffeine: 15, fat: 12, sugar: 34, protein: 11)
        let hotChocolateGrande = Nutrition(calories: 410, caffeine: 20, fat: 16, sugar: 43, protein: 14)
        let hotChocolateVenti = Nutrition(calories: 500, caffeine: 25, fat: 19, sugar: 52, protein: 17)
        
        let hotChocolate = Drink(
            name: "热巧克力",
            description: "浓郁的巧克力与蒸汽牛奶混合，顶部饰以鲜奶油，温暖甜蜜。",
            imageURL: "https://www.starbucks.com.cn/images/products/hot-chocolate.jpg",
            category: .hotChocolate,
            nutritionTall: hotChocolateTall,
            nutritionGrande: hotChocolateGrande,
            nutritionVenti: hotChocolateVenti
        )
        drinks.append(hotChocolate)
        
        // 添加更多饮品...
        
        return drinks
    }
} 