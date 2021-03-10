import Foundation
public enum RemoteError: Swift.Error {
    case connectivity
    case invalidData
}

open class RemoteLoader<Output: ExpressibleByArrayLiteral>: ItemsLoader {
    private let url: URL
    private let client: HTTPClient
    private let mapper: Mapper
    public typealias Mapper = (Data, HTTPURLResponse) throws -> Output
    public typealias Error = RemoteError

    //	public typealias Result = FeedLoader.Result

    public init(url: URL, client: HTTPClient, mapper: @escaping Mapper) {
        self.url = url
        self.client = client
        self.mapper = mapper
    }

    public func load(completion: @escaping (Outcome) -> Void) {
        client.get(from: url) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success((data, response)):
                completion(self.map(data, from: response))

            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }

    private func map(_ data: Data, from response: HTTPURLResponse) -> Outcome {
        do {
            let items = try mapper(data, response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}
