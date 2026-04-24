//
//  ContentView.swift
//  CourseMarket

//

import SwiftUI
import SwiftData

enum AppRoute: Hashable {
    case auth
    case main(user: User)
}

final class Router: ObservableObject {
    static let shared = Router()
    
    @Published var path: [AppRoute] = []
    
    func logout() {
        path = [.auth]
    }
}

struct ContentView: View {
    @ObservedObject var router = Router.shared

    var body: some View {
        NavigationStack(path: $router.path) {
            AuthView(onAuthSuccess: { user in
                router.path.append(.main(user: user))
            })
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .auth:
                    AuthView(onAuthSuccess: { user in
                        router.path.append(.main(user: user))
                    })
                case .main(let user):
                    MainTabView(currentUser: user)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Course.self, inMemory: true)
}
