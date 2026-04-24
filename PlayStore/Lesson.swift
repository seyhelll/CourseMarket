import Foundation
import SwiftData

@Model
final class Lesson {
    var id: UUID
    var courseId: UUID
    var title: String
    var videoUrl: String
    var duration: Int // seconds
    var order: Int
    
    init(id: UUID = UUID(), courseId: UUID, title: String, videoUrl: String, duration: Int, order: Int) {
        self.id = id
        self.courseId = courseId
        self.title = title
        self.videoUrl = videoUrl
        self.duration = duration
        self.order = order
    }
}
