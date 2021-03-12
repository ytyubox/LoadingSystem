import Foundation

public protocol Loader {
    associatedtype Output
    typealias Outcome = Swift.Result<Output, Error>
    typealias Promise = (Outcome) -> Void

    func load(completion: @escaping Promise)
}

public protocol ItemsLoader: Loader where Output: ExpressibleByArrayLiteral {}

private class LoaderBaseBox<Output>: Loader {
    init() {}
    func load(completion _: @escaping Promise) {
        fatalError()
    }
}

private final class LoaderBox<FeedLoaderType: Loader>: LoaderBaseBox<FeedLoaderType.Output> {
    let base: FeedLoaderType
    init(base: FeedLoaderType) {
        self.base = base
        super.init()
    }

    override func load(completion: @escaping Promise) {
        base.load(completion: completion)
    }
}

struct AnyLoader<Output>: Loader {
    private let box: LoaderBaseBox<Output>

    init<F: Loader>(_ future: F) where Output == F.Output {
        if let earsed = future as? AnyLoader<Output> {
            box = earsed.box
        } else {
            box = LoaderBox(base: future)
        }
    }

    func load(completion: @escaping Promise) {
        box.load(completion: completion)
    }
}

extension Loader {
    func toAnyLoader() -> AnyLoader<Output> {
        AnyLoader(self)
    }
}
