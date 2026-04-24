
import SwiftUI

struct MainTabView: View {
    let currentUser: User
    
    var body: some View {
        TabView {
            // Вкладка 1: Каталог курсов
            CourseListView(currentUser: currentUser)
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Курсы")
                }
            
            // Вкладка 2: Корзина (только для студентов)
            if currentUser.role == "student" {
                CartView(currentUser: currentUser)
                    .tabItem {
                        Image(systemName: "cart.fill")
                        Text("Корзина")
                    }
            }
            
            // Вкладка 3: Избранное / Отложенное (для студентов)
            if currentUser.role == "student" {
                WishlistView(currentUser: currentUser)
                    .tabItem {
                        Image(systemName: "heart.fill")
                        Text("Избранное")
                    }
            }
            
            // Вкладка 4: Профиль
            ProfileView(user: currentUser)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Профиль")
                }
        }
        .accentColor(.blue)
    }
}

// MARK: - CartView (Корзина)
struct CartView: View {
    let currentUser: User
    @Environment(\.modelContext) private var modelContext
    @Query private var cartItems: [CartItem]
    @State private var showCheckoutAlert: Bool = false
    
    private var userCartItems: [CartItem] {
        cartItems.filter { $0.userEmail == currentUser.email }
    }
    
    private var totalPrice: Double {
        userCartItems.reduce(0) { $0 + $1.coursePrice }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if userCartItems.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "cart")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        Text("Корзина пуста")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Добавьте курсы, чтобы продолжить")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(userCartItems) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.courseTitle)
                                        .font(.headline)
                                    Text("\(Int(item.coursePrice)) ₽")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                                Spacer()
                                Button(action: {
                                    removeFromCart(item)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: deleteItems)
                        
                        Section {
                            HStack {
                                Text("Итого:")
                                    .font(.headline)
                                Spacer()
                                Text("\(Int(totalPrice)) ₽")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    
                    Button(action: checkout) {
                        HStack {
                            Image(systemName: "creditcard.fill")
                            Text("Оформить заказ (\(userCartItems.count) курсов)")
                        }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationTitle("Корзина")
            .toolbar {
                if !userCartItems.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Очистить") {
                            clearCart()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .alert("Заказ оформлен!", isPresented: $showCheckoutAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Спасибо за покупку! Доступ к курсам открыт в разделе \"Мои курсы\".")
            }
        }
    }
    
    private func removeFromCart(_ item: CartItem) {
        modelContext.delete(item)
        try? modelContext.save()
    }
    
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let item = userCartItems[index]
            modelContext.delete(item)
        }
        try? modelContext.save()
    }
    
    private func clearCart() {
        for item in userCartItems {
            modelContext.delete(item)
        }
        try? modelContext.save()
    }
    
    private func checkout() {
        // Здесь будет интеграция с платежным шлюзом
        clearCart()
        showCheckoutAlert = true
    }
}

// MARK: - WishlistView (Избранное)
struct WishlistView: View {
    let currentUser: User
    @Environment(\.modelContext) private var modelContext
    @Query private var wishlistItems: [WishlistItem]
    @Query private var courses: [Course]
    
    private var userWishlistItems: [WishlistItem] {
        wishlistItems.filter { $0.userEmail == currentUser.email }
    }
    
    private var wishedCourses: [Course] {
        let wishedIds = Set(userWishlistItems.map { $0.courseId })
        return courses.filter { wishedIds.contains($0.id) }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if wishedCourses.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "heart")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        Text("Избранное пусто")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Добавляйте курсы в избранное, чтобы не потерять")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List(wishedCourses) { course in
                        NavigationLink(destination: CourseDetailView(course: course, currentUser: currentUser)) {
                            HStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue.opacity(0.2))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Image(systemName: "book.fill")
                                            .foregroundColor(.blue)
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(course.title)
                                        .font(.headline)
                                        .lineLimit(1)
                                    Text("\(Int(course.price)) ₽")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    removeFromWishlist(course)
                                }) {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Избранное")
        }
    }
    
    private func removeFromWishlist(_ course: Course) {
        if let item = wishlistItems.first(where: { $0.courseId == course.id && $0.userEmail == currentUser.email }) {
            modelContext.delete(item)
            try? modelContext.save()
        }
    }
}

// MARK: - WishlistItem Model
@Model
final class WishlistItem {
    var id: UUID
    var userEmail: String
    var courseId: UUID
    var addedAt: Date
    
    init(id: UUID = UUID(), userEmail: String, courseId: UUID, addedAt: Date = Date()) {
        self.id = id
        self.userEmail = userEmail
        self.courseId = courseId
        self.addedAt = addedAt
    }
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, Course.self, CartItem.self, WishlistItem.self, configurations: config)
    
    let sampleStudent = User(email: "student@example.com", password: "123", role: "student")
    let sampleAuthor = User(email: "author@example.com", password: "123", role: "author")
    
    let sampleCourses = [
        Course(title: "SwiftUI продвинутый", courseDescription: "", price: 5990, imageUrl: "", authorName: "Иван", authorId: UUID(), category: "Программирование", trailerUrl: "", rating: 4.9, lessonsCount: 20),
        Course(title: "UX исследование", courseDescription: "", price: 3990, imageUrl: "", authorName: "Мария", authorId: UUID(), category: "Дизайн", trailerUrl: "", rating: 4.7, lessonsCount: 14)
    ]
    
    for course in sampleCourses {
        container.mainContext.insert(course)
    }
    container.mainContext.insert(sampleStudent)
    container.mainContext.insert(sampleAuthor)
    
    return MainTabView(currentUser: sampleStudent)
        .modelContainer(container)
}
