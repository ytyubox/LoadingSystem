//
/*
 *		Created by 游宗諭 in 2021/3/10
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 11.2
 */
import Foundation
import LoadingSystem
public final class RemoteFeedLoader: RemoteLoader<[FeedImage]> {
    public convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client) {
            data, response in
            try FeedItemsMapper.map(data, from: response).toModels()
        }
    }
}

extension RemoteFeedItem: RemoteModel {
    typealias Model = FeedImage
    var model: Model {
        FeedImage(id: id, description: description, location: location, url: image)
    }
}
