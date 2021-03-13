import Foundation

public struct CachedItem<Local> where Local: LocalModel {
    public init(item: [Local], timestamp: Date) {
        self.item = item
        self.timestamp = timestamp
    }

    public let item: [Local]
    public let timestamp: Date
}

public protocol Store {
    typealias DeletionResult = Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void
    associatedtype Local: LocalModel
    typealias InsertionResult = Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void

    typealias Retrieval = CachedItem<Local>
    typealias RetrievalResult = Result<Retrieval?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void

    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCached(completion: @escaping DeletionCompletion)

    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(_ local: [Local], timestamp: Date, completion: @escaping InsertionCompletion)

    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(completion: @escaping RetrievalCompletion)
}

public protocol CacheItem {
    var timestamp: Date { get }
}
