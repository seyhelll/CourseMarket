TabView {
    CourseListView()
        .tabItem {
            Label("Курсы", systemImage: "book.fill")
        }
    CartView()
        .tabItem {
            Label("Корзина", systemImage: "cart.fill")
        }
    ProfileView()
        .tabItem {
            Label("Профиль", systemImage: "person.fill")
        }
}
