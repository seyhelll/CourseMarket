import SwiftUI
import SwiftData

enum AuthMode {
    case login
    case register
}

enum UserType: String, CaseIterable, Identifiable {
    case student = "Студент"
    case author = "Автор курсов"

    var id: String { rawValue }
}

struct AuthView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]

    let onAuthSuccess: (User) -> Void

    @State private var authMode: AuthMode = .login
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var selectedUserType: UserType = .student
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("CourseMarket")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 50)

            Picker(selection: $authMode, label: Text("Режим")) {
                Text("Вход").tag(AuthMode.login)
                Text("Регистрация").tag(AuthMode.register)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            VStack(spacing: 15) {
                TextField("Электронная почта", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Пароль", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                if authMode == .register {
                    Picker("Тип пользователя", selection: $selectedUserType) {
                        ForEach(UserType.allCases) { userType in
                            Text(userType.rawValue).tag(userType)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                if isLoading {
                    ProgressView()
                        .padding(.top, 10)
                }

                Button(action: handleAction) {
                    Text(authMode == .login ? "Войти" : "Зарегистрироваться")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isLoading ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isLoading)
            }
            .padding(.horizontal)

            Spacer()
        }
        .alert("Ошибка", isPresented: $showAlert) {
            Button("Ок", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    private func handleAction() {
        isLoading = true

        Task {
            if authMode == .register {
                if users.contains(where: { $0.email.lowercased() == email.lowercased() }) {
                    alertMessage = "Пользователь с таким email уже существует."
                    showAlert = true
                } else {
                    let newUser = User(email: email, password: password, role: selectedUserType == .student ? "student" : "author")
                    modelContext.insert(newUser)
                    onAuthSuccess(newUser)
                }
            } else {
                if let user = users.first(where: { $0.email.lowercased() == email.lowercased() }) {
                    if user.password == password {
                        onAuthSuccess(user)
                    } else {
                        alertMessage = "Неверный пароль."
                        showAlert = true
                    }
                } else {
                    alertMessage = "Пользователь не найден."
                    showAlert = true
                }
            }

            isLoading = false
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView { _ in
            
        }
    }
}
