//
//  CreateCourseView.swift
//  CourseMarket
//
//  Created by Александр Бисеров on 22.04.2025.
//

import SwiftUI
import SwiftData

struct CreateCourseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var courseDescription: String = ""
    @State private var price: String = ""
    @State private var category: String = ""
    @State private var trailerUrl: String = ""
    
    @State private var imagePickerPresented: Bool = false
    @State private var selectedImage: UIImage? = nil
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    let currentUser: User
    
    let categories = ["Программирование", "Дизайн", "Маркетинг", "Языки", "Бизнес", "Фотография", "Музыка", "Другое"]
    
    init(currentUser: User) {
        self.currentUser = currentUser
    }
    
    func saveCourse() {
        // Проверка обязательных полей
        guard !title.isEmpty else {
            alertMessage = "Введите название курса"
            showAlert = true
            return
        }
        
        guard !courseDescription.isEmpty else {
            alertMessage = "Введите описание курса"
            showAlert = true
            return
        }
        
        guard let priceValue = Double(price), priceValue > 0 else {
            alertMessage = "Введите корректную цену"
            showAlert = true
            return
        }
        
        guard !category.isEmpty else {
            alertMessage = "Выберите категорию курса"
            showAlert = true
            return
        }
        
        guard let selectedImage else {
            alertMessage = "Выберите обложку для курса"
            showAlert = true
            return
        }
        
        // Создаем новый объект курса
        let newCourse = Course(
            title: title,
            courseDescription: courseDescription,
            price: priceValue,
            imageUrl: "", // Здесь будет URL после загрузки на сервер
            authorName: currentUser.email,
            authorId: currentUser.id,
            category: category,
            trailerUrl: trailerUrl,
            rating: 0.0,
            lessonsCount: 0
        )
        
        // TODO: Загрузить изображение на сервер и получить URL
        // Пока сохраняем локально
        modelContext.insert(newCourse)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            alertMessage = "Ошибка при сохранении курса: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Основная информация")) {
                    TextField("Название курса", text: $title)
                    TextField("Краткое описание", text: $courseDescription, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Цена (₽)", text: $price)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Категория")) {
                    Picker("Выберите категорию", selection: $category) {
                        Text("Не выбрано").tag("")
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                }
                
                Section(header: Text("Медиа")) {
                    Button(action: {
                        imagePickerPresented.toggle()
                    }) {
                        HStack {
                            Image(systemName: "photo.fill")
                            Text("Выбрать обложку курса")
                        }
                    }
                    
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(10)
                            .padding(.vertical, 5)
                    }
                }
                
                Section(header: Text("Видео-превью (опционально)")) {
                    TextField("Ссылка на YouTube/Vimeo", text: $trailerUrl)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
                
                Section {
                    Button(action: saveCourse) {
                        Text("Опубликовать курс")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Создать курс")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $imagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .alert("Ошибка", isPresented: $showAlert) {
                Button("ОК", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, configurations: config)
    let sampleUser = User(email: "author@example.com", password: "123", role: "author")
    
    return CreateCourseView(currentUser: sampleUser)
        .modelContainer(container)
}
