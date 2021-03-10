//
/*
 *		Created by 游宗諭 in 2021/2/4
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 10.15
 */
import Foundation
struct RemoteImageCommentItem: Codable {
    let id: UUID
    let message: String
    let createdAt: Date
    let author: Author

    enum CodingKeys: String, CodingKey {
        case id
        case message
        case createdAt = "created_at"
        case author
    }

    // MARK: - Author

    struct Author: Codable {
        let username: String

        enum CodingKeys: String, CodingKey {
            case username
        }
    }
}
