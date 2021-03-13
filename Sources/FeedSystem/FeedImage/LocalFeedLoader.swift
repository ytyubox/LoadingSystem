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
public final class LocalFeedLoader<AStore: Store>: LocalLoader<[FeedImage], AStore> where AStore.Local == LocalFeedImage {
    public convenience init(store: AStore, currentDate: @escaping () -> Date) {
        self.init(store: store, currentDate: currentDate) {
            cache in
            cache.item.toModels()
        }
    }
}

extension FeedImage: AModel {
    public typealias Local = LocalFeedImage
    public var local: LocalFeedImage {
        LocalFeedImage(id: id, description: description, location: location, url: url)
    }
}

extension LocalFeedImage: LocalModel {
    public typealias Model = FeedImage
    public var model: Model {
        FeedImage(id: id, description: description, location: location, url: url)
    }
}
