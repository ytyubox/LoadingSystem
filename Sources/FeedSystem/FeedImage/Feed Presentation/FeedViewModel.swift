import LoadingSystem
public typealias FeedViewModel = ItemsViewModel<FeedImage>

//public struct FeedViewModel {
//    public let feed: [FeedImage]
//}
extension FeedViewModel {
    init(feed: [FeedImage]) {
        self.init(items: feed)
    }
    var feed: [FeedImage] {
        self.items
    }
}
