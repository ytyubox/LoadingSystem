//
/*
 *		Created by 游宗諭 in 2021/2/4
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 10.15
 */
import Foundation
public struct ImageComment: Equatable {
    public init(id: UUID, message: String, createdAt: Date, author: ImageComment.Author) {
        self.id = id
        self.message = message
        self.createdAt = createdAt
        self.author = author
    }

    let id: UUID
    let message: String
    let createdAt: Date
    let author: Author
    public struct Author: Equatable {
        public init(username: String) {
            self.username = username
        }

        let username: String
    }
}
