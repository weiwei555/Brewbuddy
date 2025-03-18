//
//  ContentView.swift
//  Brewbuddy
//
//  Created by 吴炜 on 3/16/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var drinks: [Drink]
    @StateObject private var viewModel = DrinkViewModel()
    @State private var isLoading = true
    @State private var showingDrinkDetail = false
    @State private var selectedDrink: Drink?
    @State private var showingFilterSheet = false
    @State private var showingFavorites = false
    
    // 滚动相关状态
    @State private var scrollOffset: CGFloat = 0
    @State private var showScrollToTop = false
    @State private var showFloatingFavoriteButton = false
    
    // 时间相关状态
    @State private var currentHour = Calendar.current.component(.hour, from: Date())
    
    var body: some View {
        ZStack {
            // 背景 - 米黄色到白色的温柔渐变
            backgroundView
            
            if isLoading {
                // 加载状态
                loadingView
            } else {
                // 主内容 - 单一滚动视图
                mainScrollView
                
                // 浮动回到顶部按钮
                if showScrollToTop {
                    scrollToTopButton
                }
                
                // 浮动收藏按钮
                if showFloatingFavoriteButton {
                    floatingFavoriteButton
                }
            }
        }
        .sheet(isPresented: $showingDrinkDetail, onDismiss: {
            // 重置选择
            selectedDrink = nil
        }) {
            if let drink = selectedDrink {
                NavigationStack {
                    DrinkDetailView(drink: drink, viewModel: viewModel)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("关闭") {
                                    showingDrinkDetail = false
                                }
                            }
                        }
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
        .sheet(isPresented: $showingFilterSheet) {
            FilterSheetView(viewModel: viewModel)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingFavorites) {
            FavoritesView(viewModel: viewModel)
        }
        .onAppear {
            // 清除旧数据并重新加载
            clearAndReloadData()
            
            // 模拟加载过程
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isLoading = false
                }
            }
        }
    }
    
    // 清除旧数据并重新加载
    private func clearAndReloadData() {
        // 清除现有数据
        do {
            try modelContext.delete(model: Drink.self)
            try modelContext.delete(model: Nutrition.self)
            print("成功清除旧数据")
        } catch {
            print("清除数据时出错: \(error)")
        }
        
        // 加载新数据
        DataManager.preloadSampleData(modelContext: modelContext)
    }
    
    // 背景视图 - 米黄色到白色的温柔渐变
    private var backgroundView: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.98, green: 0.95, blue: 0.9), // 米黄色
                Color.white
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    // 加载视图
    private var loadingView: some View {
        VStack(spacing: 20) {
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 70))
                .foregroundColor(Color.brown)
                .symbolEffect(.pulse, options: .repeating)
            
            Text("正在准备您的咖啡...")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(Color.brown)
        }
    }
    
    // 主滚动视图 - 整合筛选控件和饮品列表
    private var mainScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                // 使用GeometryReader跟踪滚动位置
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geometry.frame(in: .named("scrollView")).minY
                    )
                }
                .frame(height: 0)
                
                VStack(spacing: 0) {
                    // 欢迎区域 - 只在顶部或上滑时显示
                    welcomeSection
                        .id("top")
                    
                    // 筛选控件区域
                    filterSection
                        .id("filters")
                    
                    // 饮品列表
                    drinkListSection
                }
                .padding(.bottom, 20)
            }
            .coordinateSpace(name: "scrollView")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                // 更新滚动偏移量
                scrollOffset = offset
                
                // 当滚动超过一定距离时显示回到顶部按钮
                withAnimation {
                    showScrollToTop = offset < -200
                    
                    // 当滚动超过筛选区域时显示浮动收藏按钮
                    showFloatingFavoriteButton = offset < -300
                }
            }
            .onChange(of: showScrollToTop) { _, newValue in
                // 当回到顶部按钮出现时提供触觉反馈
                if newValue {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
            }
            
            // 浮动回到顶部按钮的点击动作
            .onChange(of: showScrollToTop) { _, newValue in
                if !newValue {
                    withAnimation {
                        proxy.scrollTo("top", anchor: .top)
                    }
                }
            }
        }
    }
    
    // 欢迎区域
    private var welcomeSection: some View {
        VStack(spacing: 15) {
            // 问候语
            Text(timeBasedGreeting)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.brown)
            
            Text("探索您喜爱的星巴克饮品")
                .font(.title3)
                .foregroundColor(Color.brown.opacity(0.8))
            
            // 装饰性咖啡杯图标
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 40))
                .foregroundColor(Color.brown.opacity(0.7))
                .padding(.top, 5)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
        .padding(.bottom, 30)
        .background(
            // 底部渐变遮罩，创造平滑过渡
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.98, green: 0.95, blue: 0.9).opacity(0),
                    Color(red: 0.98, green: 0.95, blue: 0.9)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 50)
            .offset(y: 30),
            alignment: .bottom
        )
        // 根据滚动位置调整透明度
        .opacity(min(1, 1 + scrollOffset / 100))
    }
    
    // 筛选控件区域
    private var filterSection: some View {
        VStack(spacing: 25) {
            // 顶部操作按钮
            HStack {
                // 筛选按钮
                Button(action: {
                    showingFilterSheet = true
                    // 触觉反馈
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "slider.horizontal.3")
                        Text("筛选")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.brown.opacity(0.1))
                    .foregroundColor(Color.brown)
                    .cornerRadius(8)
                }
                
                Spacer()
                
                // 收藏按钮
                Button(action: {
                    showingFavorites = true
                    // 触觉反馈
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                        Text("我的收藏")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(Color.red)
                    .cornerRadius(8)
                }
            }
            
            // 卡路里滑块
            SliderControl(
                value: $viewModel.caloriesThreshold,
                range: 100...600,
                title: "卡路里上限",
                icon: "flame.fill",
                color: .orange,
                formatter: { "\(Int($0))" }
            )
            
            // 咖啡因滑块
            SliderControl(
                value: $viewModel.caffeineThreshold,
                range: 50...400,
                title: "咖啡因上限",
                icon: "bolt.fill",
                color: .blue,
                formatter: { "\(Int($0)) mg" }
            )
            
            // 饮品类别选择
            categorySelectionView
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 16)
        .padding(.top, max(0, -scrollOffset - 30)) // 创建卡点效果
    }
    
    // 饮品列表区域
    private var drinkListSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            // 列表标题
            Text("饮品列表")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.brown)
                .padding(.horizontal, 20)
                .padding(.top, 30)
            
            // 饮品列表
            let filteredDrinks = viewModel.filteredDrinks(drinks: drinks)
            
            if filteredDrinks.isEmpty {
                // 无结果状态
                VStack(spacing: 20) {
                    Image(systemName: "cup.and.saucer")
                        .font(.system(size: 60))
                        .foregroundColor(Color.brown.opacity(0.5))
                    
                    Text("没有找到符合条件的饮品")
                        .font(.headline)
                        .foregroundColor(Color.brown)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, minHeight: 300)
                .padding()
            } else {
                // 饮品列表
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
                    ForEach(filteredDrinks) { drink in
                        DrinkCard(drink: drink)
                            .frame(height: 280)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                print("点击了饮品: \(drink.name)")
                                selectedDrink = drink
                                showingDrinkDetail = true
                                
                                // 触觉反馈
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                            }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.bottom, 20)
    }
    
    // 浮动回到顶部按钮
    private var scrollToTopButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showScrollToTop = false
            }
            
            // 触觉反馈
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }) {
            Image(systemName: "arrow.up")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.brown)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .transition(.scale.combined(with: .opacity))
    }
    
    // 类别选择视图
    private var categorySelectionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("饮品类别")
                .font(.headline)
                .foregroundColor(Color.brown)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(DrinkCategory.allCases) { category in
                        CategoryButton(
                            category: category,
                            isSelected: viewModel.selectedCategories.contains(category),
                            action: {
                                viewModel.toggleCategory(category)
                                // 触觉反馈
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            }
                        )
                    }
                }
                .padding(.horizontal, 5)
            }
        }
    }
    
    // 浮动收藏按钮
    private var floatingFavoriteButton: some View {
        Button(action: {
            showingFavorites = true
            
            // 触觉反馈
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "heart.fill")
                Text("收藏")
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.red)
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
        }
        .padding(.trailing, 20)
        .padding(.bottom, showScrollToTop ? 80 : 20) // 如果回到顶部按钮显示，则调整位置
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    // 根据时间获取问候语
    private var timeBasedGreeting: String {
        let hour = currentHour
        
        if hour >= 6 && hour < 12 {
            return "早上好"
        } else if hour >= 12 && hour < 18 {
            return "下午好"
        } else {
            return "晚上好"
        }
    }
}

// 滚动偏移量偏好键
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// 滑块控件
struct SliderControl: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let title: String
    let icon: String
    let color: Color
    let formatter: (Double) -> String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color.brown)
                
                Spacer()
                
                Text(formatter(value))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
            
            HStack(spacing: 15) {
                // 最小值标签
                Text(formatter(range.lowerBound))
                    .font(.caption2)
                    .foregroundColor(Color.gray)
                
                // 滑块
                Slider(value: $value, in: range) { editing in
                    if !editing {
                        // 触觉反馈
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                }
                .tint(color)
                
                // 最大值标签
                Text(formatter(range.upperBound))
                    .font(.caption2)
                    .foregroundColor(Color.gray)
            }
        }
    }
}

// 类别按钮
struct CategoryButton: View {
    let category: DrinkCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                // 类别图标
                Image(systemName: categoryIcon(for: category))
                    .font(.system(size: 12))
                
                // 类别名称
                Text(category.rawValue)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? categoryColor(for: category) : Color.gray.opacity(0.1))
            )
            .foregroundColor(isSelected ? .white : Color.brown)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // 根据分类返回对应的图标
    private func categoryIcon(for category: DrinkCategory) -> String {
        switch category {
        case .coffee:
            return "cup.and.saucer.fill"
        case .tea:
            return "leaf.fill"
        case .refreshers:
            return "drop.fill"
        case .frappuccino:
            return "snow"
        case .coldBrew:
            return "thermometer.snowflake"
        case .espresso:
            return "smallcircle.filled.circle.fill"
        case .hotChocolate:
            return "mug.fill"
        case .other:
            return "ellipsis.circle.fill"
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

// 筛选表单视图
struct FilterSheetView: View {
    @ObservedObject var viewModel: DrinkViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("卡路里和咖啡因")) {
                    VStack(alignment: .leading, spacing: 20) {
                        // 卡路里滑块
                        VStack(alignment: .leading, spacing: 8) {
                            Text("卡路里上限: \(Int(viewModel.caloriesThreshold))")
                                .font(.subheadline)
                            
                            Slider(value: $viewModel.caloriesThreshold, in: 100...600, step: 10)
                                .tint(.orange)
                        }
                        
                        // 咖啡因滑块
                        VStack(alignment: .leading, spacing: 8) {
                            Text("咖啡因上限: \(Int(viewModel.caffeineThreshold)) mg")
                                .font(.subheadline)
                            
                            Slider(value: $viewModel.caffeineThreshold, in: 50...400, step: 10)
                                .tint(.blue)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("饮品类别")) {
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
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Section {
                    Button("重置筛选条件") {
                        viewModel.resetFilters()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("筛选选项")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Drink.self, inMemory: true)
}
