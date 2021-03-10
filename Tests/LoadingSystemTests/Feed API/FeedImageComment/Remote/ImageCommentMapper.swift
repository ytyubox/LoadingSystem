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
enum ImageCommentMapper {
    private struct Root: Decodable {
        let items: [RemoteImageCommentItem]
    }

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss+0000"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return decoder
    }()

    static func map(_ data: Data, from _: HTTPURLResponse) throws -> [RemoteImageCommentItem] {
        guard let root = try? decoder
            .decode(Root.self, from: data)
        else {
            throw RemoteError.invalidData
        }

        return root.items
    }
}
