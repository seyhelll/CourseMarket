import Foundation
import SwiftData

@Model
final class Course {
    var id: UUID
    var title: String
    var courseDescription: String
    var price: Double
    var imageUrl: String
    var authorName: String
    var authorId: UUID
    var category: String
    var trailerUrl: String
    var rating: Double
    var lessonsCount: Int
    
    init(id: UUID = UUID(), title: String, courseDescription: String, price: Double, imageUrl: String, authorName: String, authorId: UUID, category: String, trailerUrl: String, rating: Double = 0.0, lessonsCount: Int = 0) {
        self.id = id
        self.title = title
        self.courseDescription = courseDescription
        self.price = price
        self.imageUrl = imageUrl
        self.authorName = authorName
        self.authorId = authorId
        self.category = category
        self.trailerUrl = trailerUrl
        self.rating = rating
        self.lessonsCount = lessonsCount
    }
}
