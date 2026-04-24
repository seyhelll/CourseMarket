//
//  CourseListView.swift
//  CourseMarket
//
//  Created by Александр Бисеров on 22.04.2025.
//

import SwiftUI
import SwiftData

struct CourseListView: View {
    @Environment(\.modelContext) private var modelContext
    let currentUser: User
    
    @State private var searchQuery: String = ""
    @State private var selectedCategory: String = "Все"
        
    @Query private var courses: [Course]
    
    private var isAuthor: Bool {
        currentUser.role == "author"
    }
    
    private var categories: [String] {
        let allCategories = courses.map { $0.category }
        let uniqueCategories = Array(Set(allCategories))
        return ["Все"] + uniqueCategories.sorted()
    }
    
    private var filteredCourses: [Course] {
        var result = courses
        
        // Фильтрация по автору (для автора показываем только его курсы)
        if isAuthor {
            result = result.filter { $0.authorId == currentUser.id }
        }
        
        // Фильтрация по поисковому запросу
        if !searchQuery.isEmpty {
            result = result.filter {
                $0.title.lowercased().contains(searchQuery.lowercased()) ||
                $0.courseDescription.lowercased().contains(searchQuery.lowercased()) ||
                $0.authorName.lowercased().contains(searchQuery.lowercased())
            }
        }
        
        // Фильтрация по категории
        if selectedCategory != "Все" {
            result = result.filter { $0.category == selectedCategory }
        }
        
        return result
    }
    
    init(currentUser: User) {
        self.currentUser = currentUser
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Категории (горизонтальный скролл)
                if !isAuthor {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(categories, id: \.self) { category in
                                CategoryChip(
                                    title: category,
                                    isSelected: selectedCategory == category,
                                    action: { selectedCategory = category }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                }
                
                List(filteredCourses) { course in
                    if isAuthor {
                        CourseRow(course: course)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    deleteCourse(course)
                                } label: {
                                    Label("Удалить", systemImage: "trash")
                                }
                                
                                NavigationLink(destination: EditCourseView(course: course, currentUser: currentUser)) {
                                    Label("Редактировать", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                    } else {
                        NavigationLink(destination: CourseDetailView(course: course, currentUser: currentUser)) {
                            CourseRow(course: course)
                        }
                    }
                }
                .listStyle(.plain)
                .navigationTitle(isAuthor ? "Мои курсы" : "Каталог курсов")
            }
            .toolbar {
                if isAuthor {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: CreateCourseView(currentUser: currentUser)) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Создать курс")
                            }
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        }
                    }
                }
            }
            .searchable(text: $searchQuery, prompt: "Поиск по названию, описанию или автору")
        }
    }
    
    private func deleteCourse(_ course: Course) {
        modelContext.delete(course)
        try? modelContext.save()
    }
}

// MARK: - CourseRow
struct CourseRow: View {
    var course: Course
    
    var body: some View {
        HStack(spacing: 12) {
            // Обложка курса (заглушка, если нет изображения)
            if let imageData = course.imageUrl.data(using: .utf8) {
                // Здесь должна быть загрузка из URL, пока заглушка
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "book.fill")
                            .foregroundColor(.gray)
                    )
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "book.fill")
                            .foregroundColor(.blue)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(course.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(course.authorName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("\(course.price, specifier: "%.0f") ₽")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    if course.rating > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                            Text("\(course.rating, specifier: "%.1f")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Spacer()
            
            if course.lessonsCount > 0 {
                Text("\(course.lessonsCount) уроков")
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - CategoryChip
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - EditCourseView (заглушка)
struct EditCourseView: View {
    let course: Course
    let currentUser: User
    
    var body: some View {
        Text("Редактирование курса: \(course.title)")
            .navigationTitle("Редактировать")
    }
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Course.self, User.self, configurations: config)
    
    let sampleAuthor = User(email: "author@example.com", password: "123", role: "author")
    let sampleStudent = User(email: "student@example.com", password: "123", role: "student")
    
    let sampleCourses = [
        Course(title: "iOS разработка", courseDescription: "Полный курс по SwiftUI", price: 4990, imageUrl: "", authorName: "Иван Иванов", authorId: sampleAuthor.id, category: "Программирование", trailerUrl: "", rating: 4.8, lessonsCount: 24),
        Course(title: "UI/UX дизайн", courseDescription: "Основы Figma", price: 3990, imageUrl: "", authorName: "Мария Петрова", authorId: UUID(), category: "Дизайн", trailerUrl: "", rating: 4.5, lessonsCount: 18)
    ]
    
    for course in sampleCourses {
        container.mainContext.insert(course)
    }
    container.mainContext.insert(sampleAuthor)
    container.mainContext.insert(sampleStudent)
    
    return CourseListView(currentUser: sampleStudent)
        .modelContainer(container)
}
