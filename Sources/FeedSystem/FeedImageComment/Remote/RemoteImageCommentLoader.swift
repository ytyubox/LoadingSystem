//
/*
 *		Created by 游宗諭 in 2021/2/4
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 10.15
 */
import Foundation
import LoadingSystem
public final class RemoteImageCommentLoader: CancellableLoaderOwner {
    public typealias CancellableOutput = [ImageComment]

    public let client: HTTPClient
    public let mapper: Mapper

    public init(client: HTTPClient) {
        self.client = client
        mapper = {
            data, response in
            try Self.thowIfNot2XX(response: response)
            return try ImageCommentMapper.map(data, from: response).map(\.model)
        }
    }

    private static func thowIfNot2XX(response: HTTPURLResponse) throws {
        guard (200 ..< 300).contains(response.statusCode) else {
            throw RemoteError.invalidData
        }
    }
}

extension RemoteImageCommentItem {
    var model: ImageComment {
        .init(id: id, message: message, createdAt: createdAt, author: ImageComment.Author(username: author.username))
    }
}
