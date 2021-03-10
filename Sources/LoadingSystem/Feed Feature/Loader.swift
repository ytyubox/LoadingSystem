import Foundation

public protocol Loader {
    associatedtype Output
    typealias Outcome = Swift.Result<Output, Error>
    typealias Promise = (Outcome) -> Void

    func load(completion: @escaping Promise)
}

public protocol ItemsLoader: Loader where Output: ExpressibleByArrayLiteral {}

private class FeedLoaderBaseBox<Output: ExpressibleByArrayLiteral>: ItemsLoader {
    init() {}
    func load(completion _: @escaping Promise) {
        fatalError()
    }
}

private final class FeedLoaderBox<FeedLoaderType: ItemsLoader>: FeedLoaderBaseBox<FeedLoaderType.Output> {
    let base: FeedLoaderType
    init(base: FeedLoaderType) {
        self.base = base
        super.init()
    }

    override func load(completion: @escaping Promise) {
        base.load(completion: completion)
    }
}

struct AnyFeedLoader<Output: ExpressibleByArrayLiteral>: ItemsLoader {
    private let box: FeedLoaderBaseBox<Output>

    init<F: ItemsLoader>(_ future: F) where Output == F.Output {
        if let earsed = future as? AnyFeedLoader<Output> {
            box = earsed.box
        } else {
            box = FeedLoaderBox(base: future)
        }
    }

    func load(completion: @escaping Promise) {
        box.load(completion: completion)
    }
}
