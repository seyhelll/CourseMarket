import Foundation
import SwiftData

@Model
final class CartItem {
    var id: UUID
    var userEmail: String
    var courseId: UUID
    var courseTitle: String
    var coursePrice: Double
    
    init(id: UUID = UUID(), userEmail: String, courseId: UUID, courseTitle: String, coursePrice: Double) {
        self.id = id
        self.userEmail = userEmail
        self.courseId = courseId
        self.courseTitle = courseTitle
        self.coursePrice = coursePrice
    }
}
