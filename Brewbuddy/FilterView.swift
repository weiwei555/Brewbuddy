//
//  FilterView.swift
//  Brewbuddy
//
//  Created by 吴炜 on 3/16/25.
//

import SwiftUI

struct FilterView: View {
    @ObservedObject var viewModel: DrinkViewModel
    @Environment(\.dismiss) private var dismiss
    @Namespace private var animation
    
    var body: some View {
        NavigationStack {
            Form {
                // 杯型选择
                Section(header: Text("杯型选择")) {
                    Picker("选择杯型", selection: $viewModel.selectedSize) {
                        ForEach(DrinkSize.allCases) { size in
                            Text(size.rawValue).tag(size)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // 卡路里筛选
                Section(header: Text("卡路里上限")) {
                    VStack {
                        HStack {
                            Text("最大卡路里: \(Int(viewModel.caloriesThreshold))")
                                .font(.headline)
                            Spacer()
                            Text("卡路里")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(
                            value: $viewModel.caloriesThreshold,
                            in: 0...600,
                            step: 10
                        ) {
                            Text("卡路里上限")
                        } minimumValueLabel: {
                            Text("0")
                                .font(.caption)
                        } maximumValueLabel: {
                            Text("600")
                                .font(.caption)
                        }
                        .tint(.orange)
                    }
                }
                
                // 咖啡因筛选
                Section(header: Text("咖啡因上限")) {
                    VStack {
                        HStack {
                            Text("最大咖啡因: \(Int(viewModel.caffeineThreshold))")
                                .font(.headline)
                            Spacer()
                            Text("毫克")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(
                            value: $viewModel.caffeineThreshold,
                            in: 0...500,
                            step: 10
                        ) {
                            Text("咖啡因上限")
                        } minimumValueLabel: {
                            Text("0")
                                .font(.caption)
                        } maximumValueLabel: {
                            Text("500")
                                .font(.caption)
                        }
                        .tint(.blue)
                    }
                }
                
                // 分类筛选
                Section(header: Text("饮品分类")) {
                    ForEach(DrinkCategory.allCases) { category in
                        Button(action: {
                            viewModel.toggleCategory(category)
                        }) {
                            HStack {
                                Text(category.rawValue)
                                Spacer()
                                if viewModel.selectedCategories.contains(category) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                        .matchedGeometryEffect(id: category.id, in: animation)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .navigationTitle("筛选选项")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("重置") {
                        withAnimation {
                            viewModel.resetFilters()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}

#Preview {
    FilterView(viewModel: DrinkViewModel())
} 