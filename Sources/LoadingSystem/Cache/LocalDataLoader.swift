import Foundation

public final class LocalDataLoader {
    private let store: DataStore

    public init(store: DataStore) {
        self.store = store
    }
}

extension LocalDataLoader: DataCache {
    public typealias SaveResult = DataCache.Result

    public enum SaveError: Error {
        case failed
    }

    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: url) { [weak self] result in
            guard self != nil else { return }

            completion(result.mapError { _ in SaveError.failed })
        }
    }
}

extension LocalDataLoader: CancelableLoader {
    public typealias Output = Data



    public enum LoadError: Error {
        case failed
        case notFound
    }

    private final class LoadImageDataTask: CancellabelTask {
        private var completion: ((Outcome) -> Void)?

        init(_ completion: @escaping (Outcome) -> Void) {
            self.completion = completion
        }

        func complete(with result: Outcome) {
            completion?(result)
        }

        func cancel() {
            preventFurtherCompletions()
        }

        private func preventFurtherCompletions() {
            completion = nil
        }
    }

    public func load(from url: URL, completion: @escaping Promise) -> CancellabelTask {
        let task = LoadImageDataTask(completion)
        store.retrieve(dataForURL: url) { [weak self] result in
            guard self != nil else { return }

            task.complete(with: result
                .mapError { _ in LoadError.failed }
                .flatMap { data in
                    data.map { .success($0) } ?? .failure(LoadError.notFound)
                })
        }
        return task
    }
}
