import Foundation
import SwiftData

@Model
final class User {
    var email: String
    var password: String
    var role: String // "student" or "author"
    
    init(email: String, password: String, role: String = "student") {
        self.email = email
        self.password = password
        self.role = role
    }
}
