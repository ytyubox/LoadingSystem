import Foundation
import LoadingSystem
public protocol FeedView: ItemsView where Item == FeedImage {}
public typealias FeedLoadingView = LoadingView
public typealias FeedErrorView = ErrorView


public final class FeedPresenter<SuccessView: FeedView>: Presenter<FeedImage, SuccessView>  {
    
    private static var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                                 tableName: "Feed",
                                 bundle: .module,
                                 comment: "Error message displayed when we can't load the image feed from the server")
    }

    public convenience init(feedView: SuccessView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.init(itemsView: feedView,
                  loadingView: loadingView,
                  errorView: errorView,
                  errorMessageFactory: {
                    _ in
                    Self.feedLoadError
                  }
        )
    }
   

    public static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: .module,
                                 comment: "Title for the feed view")
    }

    public func didStartLoadingFeed() {
        self.didStartLoading()
    }

    public  func didFinishLoadingFeed(with feed: [FeedImage]) {
        self.didFinishLoading(with: feed)
    }

    public func didFinishLoadingFeed(with error: Error) {
        self.didFinishLoading(with: error)
    }
}
