

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Bindable var user: User
    @Environment(\.modelContext) private var modelContext
    @Query private var authoredCourses: [Course]
    @Query private var enrolledCourses: [Course]
    
    @State private var isEditing = false
    @State private var editedEmail: String = ""
    @State private var editedPassword: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    private var isStudent: Bool {
        user.role == "student"
    }
    
    private var isAuthor: Bool {
        user.role == "author"
    }
    
    private var myCourses: [Course] {
        if isAuthor {
            return authoredCourses.filter { $0.authorId == user.id }
        } else {
            return enrolledCourses
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                // MARK: - Информация о пользователе
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(isStudent ? "Студент" : "Автор курсов")
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(isStudent ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
                                .foregroundColor(isStudent ? .green : .blue)
                                .cornerRadius(8)
                            
                            if isEditing {
                                TextField("Email", text: $editedEmail)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                
                                SecureField("Новый пароль", text: $editedPassword)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            } else {
                                InfoRow(title: "Email", value: user.email)
                                InfoRow(title: "Пароль", value: String(repeating: "•", count: min(8, user.password.count)))
                            }
                        }
                    }
                } header: {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                        Text("Личная информация")
                    }
                }
                
                // MARK: - Мои курсы
                if !myCourses.isEmpty {
                    Section {
                        ForEach(myCourses) { course in
                            NavigationLink(destination: CourseDetailView(course: course, currentUser: user)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(course.title)
                                        .font(.headline)
                                    HStack {
                                        Text("\(Int(course.price)) ₽")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                        if course.rating > 0 {
                                            HStack(spacing: 2) {
                                                Image(systemName: "star.fill")
                                                    .font(.caption2)
                                                    .foregroundColor(.yellow)
                                                Text("\(course.rating, specifier: "%.1f")")
                                                    .font(.caption)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .onDelete(perform: deleteCourses)
                    } header: {
                        HStack {
                            Image(systemName: isAuthor ? "plus.square.fill" : "book.fill")
                                .font(.title2)
                            Text(isAuthor ? "Мои курсы" : "Мои курсы")
                        }
                    }
                }
                
                // MARK: - Статистика (для автора)
                if isAuthor && !authoredCourses.isEmpty {
                    Section {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Всего курсов")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(authoredCourses.count)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Общая выручка")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(totalRevenue, specifier: "%.0f") ₽")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.vertical, 4)
                    } header: {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .font(.title2)
                            Text("Статистика")
                        }
                    }
                }
                
                // MARK: - Кнопки действий
                Section {
                    Button(action: handleEditSave) {
                        HStack {
                            Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                            Text(isEditing ? "Сохранить изменения" : "Редактировать профиль")
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(.blue)
                    }
                    
                    if !isEditing {
                        Button(action: logout) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Выйти из аккаунта")
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !isEditing {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if isAuthor {
                            NavigationLink(destination: CreateCourseView(currentUser: user)) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .alert("Ошибка", isPresented: $showAlert) {
                Button("ОК", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                loadUserData()
            }
        }
    }
    
    // MARK: - Computed Properties
    private var totalRevenue: Double {
        // Здесь должна быть логика подсчета выручки из заказов
        // Пока просто заглушка
        return Double(authoredCourses.count) * 5000
    }
    
    // MARK: - Methods
    private func handleEditSave() {
        if isEditing {
            // Сохраняем изменения
            if !editedEmail.isEmpty {
                // Проверка на уникальность email
                user.email = editedEmail
            }
            if !editedPassword.isEmpty && editedPassword.count >= 4 {
                user.password = editedPassword
            } else if !editedPassword.isEmpty {
                alertMessage = "Пароль должен содержать минимум 4 символа"
                showAlert = true
                return
            }
            
            do {
                try modelContext.save()
            } catch {
                alertMessage = "Ошибка при сохранении: \(error.localizedDescription)"
                showAlert = true
            }
        } else {
            editedEmail = user.email
            editedPassword = user.password
        }
        
        withAnimation {
            isEditing.toggle()
        }
    }
    
    private func logout() {
        Router.shared.logout()
    }
    
    private func deleteCourses(at offsets: IndexSet) {
        for index in offsets {
            let course = myCourses[index]
            modelContext.delete(course)
        }
        try? modelContext.save()
    }
    
    private func loadUserData() {
        // Дополнительная загрузка данных пользователя при необходимости
    }
}

// MARK: - InfoRow Component
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
        .font(.subheadline)
    }
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, Course.self, configurations: config)
    
    let sampleStudent = User(email: "student@example.com", password: "password123", role: "student")
    let sampleAuthor = User(email: "author@example.com", password: "password123", role: "author")
    
    let sampleCourses = [
        Course(title: "SwiftUI для начинающих", courseDescription: "", price: 3990, imageUrl: "", authorName: sampleAuthor.email, authorId: sampleAuthor.id, category: "Программирование", trailerUrl: "", rating: 4.5, lessonsCount: 12),
        Course(title: "Figma эксперт", courseDescription: "", price: 2990, imageUrl: "", authorName: sampleAuthor.email, authorId: sampleAuthor.id, category: "Дизайн", trailerUrl: "", rating: 4.2, lessonsCount: 8)
    ]
    
    for course in sampleCourses {
        container.mainContext.insert(course)
    }
    container.mainContext.insert(sampleStudent)
    container.mainContext.insert(sampleAuthor)
    
    return ProfileView(user: sampleStudent)
        .modelContainer(container)
}
