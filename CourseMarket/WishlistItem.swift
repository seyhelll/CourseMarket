//
//  WishlistItem.swift
//  CourseMarket
//

import Foundation
import SwiftData

@Model
final class WishlistItem {
    var id: UUID
    var userEmail: String
    var courseId: UUID
    var addedAt: Date
    
    init(id: UUID = UUID(), userEmail: String, courseId: UUID, addedAt: Date = Date()) {
        self.id = id
        self.userEmail = userEmail
        self.courseId = courseId
        self.addedAt = addedAt
    }
}
