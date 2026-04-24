

import SwiftUI
import SwiftData

struct CourseDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var course: Course
    var currentUser: User
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @Query private var cartItems: [CartItem]
    
    private var isInCart: Bool {
        cartItems.first(where: { $0.courseId == course.id && $0.userEmail == currentUser.email }) != nil
    }
    
    private var isAuthor: Bool {
        currentUser.role == "author" && currentUser.id == course.authorId
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Обложка курса
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 220)
                    
                    if course.imageUrl.isEmpty {
                        VStack {
                            Image(systemName: "book.closed.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("Обложка курса")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    } else {
                        // Здесь должна быть загрузка из URL
                        Image(systemName: "photo.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                
                // Название курса
                Text(course.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                // Автор
                HStack {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.blue)
                    Text(course.authorName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Рейтинг
                if course.rating > 0 {
                    HStack(spacing: 4) {
                        ForEach(0..<5, id: \.self) { index in
                            Image(systemName: index < Int(course.rating) ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                        Text("(\(course.rating, specifier: "%.1f"))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
                
                // Цена
                Text("\(Int(course.price)) ₽")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .padding(.horizontal)
                
                Divider()
                    .padding(.horizontal)
                
                // Описание курса
                VStack(alignment: .leading, spacing: 8) {
                    Text("О курсе")
                        .font(.headline)
                    Text(course.courseDescription)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.horizontal)
                
                // Информация о курсе
                VStack(alignment: .leading, spacing: 8) {
                    Text("Информация")
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "tag.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Text("Категория:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(course.category)
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Image(systemName: "book.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Text("Количество уроков:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(course.lessonsCount)")
                            .font(.subheadline)
                    }
                    
                    if !course.trailerUrl.isEmpty {
                        HStack {
                            Image(systemName: "video.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            Text("Трейлер:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Link("Смотреть превью", destination: URL(string: course.trailerUrl)!)
                                .font(.subheadline)
                        }
                    }
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.horizontal)
                
                // Кнопка действия (в зависимости от роли и статуса)
                if isAuthor {
                    // Кнопки для автора
                    VStack(spacing: 12) {
                        NavigationLink(destination: EditCourseView(course: course, currentUser: currentUser)) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Редактировать курс")
                            }
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Button(action: deleteCourse) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Удалить курс")
                            }
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                } else {
                    // Кнопка для студента
                    Button(action: toggleCart) {
                        HStack {
                            Image(systemName: isInCart ? "cart.fill.badge.minus" : "cart.badge.plus")
                            Text(isInCart ? "Убрать из корзины" : "Добавить в корзину")
                        }
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isInCart ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .disabled(currentUser.role != "student")
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(course.title)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Внимание", isPresented: $showAlert) {
            Button("ОК", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func toggleCart() {
        if currentUser.role != "student" {
            alertMessage = "Только студенты могут добавлять курсы в корзину"
            showAlert = true
            return
        }
        
        if isInCart {
            if let item = cartItems.first(where: { $0.courseId == course.id && $0.userEmail == currentUser.email }) {
                modelContext.delete(item)
            }
        } else {
            let cartItem = CartItem(
                userEmail: currentUser.email,
                courseId: course.id,
                courseTitle: course.title,
                coursePrice: course.price
            )
            modelContext.insert(cartItem)
        }
        
        do {
            try modelContext.save()
        } catch {
            alertMessage = "Ошибка: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    private func deleteCourse() {
        modelContext.delete(course)
        do {
            try modelContext.save()
            dismiss()
        } catch {
            alertMessage = "Ошибка при удалении: \(error.localizedDescription)"
            showAlert = true
        }
    }
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Course.self, User.self, CartItem.self, configurations: config)
    
    let sampleAuthor = User(email: "author@example.com", password: "123", role: "author")
    let sampleStudent = User(email: "student@example.com", password: "123", role: "student")
    
    let sampleCourse = Course(
        title: "iOS разработка на SwiftUI",
        courseDescription: "Полный курс по созданию мобильных приложений для iOS. Изучите SwiftUI, Combine, работа с сетью и базами данных.",
        price: 4990,
        imageUrl: "",
        authorName: "Иван Иванов",
        authorId: sampleAuthor.id,
        category: "Программирование",
        trailerUrl: "https://youtube.com/watch?v=example",
        rating: 4.8,
        lessonsCount: 24
    )
    
    container.mainContext.insert(sampleAuthor)
    container.mainContext.insert(sampleStudent)
    container.mainContext.insert(sampleCourse)
    
    return CourseDetailView(course: sampleCourse, currentUser: sampleStudent)
        .modelContainer(container)
}
