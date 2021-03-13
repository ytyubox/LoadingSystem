import Foundation

public protocol CancellabelTask {
    func cancel()
}

public protocol CancellableLoader {
    associatedtype CancellableOutput
    typealias Outcome = Swift.Result<CancellableOutput, Error>
    typealias Promise = (Outcome) -> Void
    typealias Mapper = (Data, HTTPURLResponse) throws -> CancellableOutput

    func load(from url: URL, completion: @escaping Promise) -> CancellabelTask
}

public protocol CancellableLoaderOwner: CancellableLoader {
    var mapper: (Data, HTTPURLResponse) throws -> CancellableOutput { get }
    var client: HTTPClient { get }
}

public extension CancellableLoaderOwner where Self: AnyObject {
    func load(from url: URL, completion: @escaping Promise) -> CancellabelTask {
        _load(loader: self, client: client, mapper: mapper, from: url, completion: completion)
    }
}

public func _load<LOADER: CancellableLoader>(loader: LOADER, client: HTTPClient, mapper: @escaping LOADER.Mapper, from url: URL, completion: @escaping LOADER.Promise) -> CancellabelTask where LOADER: AnyObject {
    let task = HTTPClientTaskWrapper(completion)
    task.wrapped = client.get(from: url) {
        [weak loader, task, mapper] result in
        guard loader != nil else { return }
        task.complete(
            with: result
                .mapError { _ in RemoteError.connectivity }
                .flatMap {
                    data, response in
                    Result { try mapper(data, response) }
                }
        )
    }
    return task
}
