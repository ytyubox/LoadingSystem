import Foundation

open class LocalLoader<Output: ExpressibleByArrayLiteral, AStore: Store> {
    private let store: AStore
    private let currentDate: () -> Date
    public typealias Mapper = (AStore.Retrieval) -> Output
    private let mapper: Mapper
    private let cachePolicy: CachePolicy.Type

    public init(store: AStore, currentDate: @escaping () -> Date, cachePolicy: CachePolicy.Type = CachePolicy.self, mapper: @escaping Mapper) {
        self.store = store
        self.currentDate = currentDate
        self.mapper = mapper
        self.cachePolicy = cachePolicy
    }
}

extension LocalLoader: ItemCache where Output.ArrayLiteralElement: AModel, Output.ArrayLiteralElement.Local == AStore.Local
{
    public typealias SaveResult = ItemCache.Result
    public typealias Item = Output.ArrayLiteralElement

    public func save(_ items: [Item], completion: @escaping (SaveResult) -> Void) {
        store.deleteCached { [weak self] deletionResult in
            guard let self = self else { return }

            switch deletionResult {
            case .success:
                self.cache(items, with: completion)

            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private func cache(_ items: [Item], with completion: @escaping (SaveResult) -> Void) {
        store.insert(items.toLocals(), timestamp: currentDate()) { [weak self] insertionResult in
            guard self != nil else { return }

            completion(insertionResult)
        }
    }
}

extension LocalLoader: ItemsLoader {
    enum LocalError: Error {
        case noValue
    }

    public func load(completion: @escaping (Outcome) -> Void) {
        store.retrieve { [weak self, cachePolicy] result in
            guard let self = self else { return }

            switch result {
            case let .failure(error):
                completion(.failure(error))

            case let .success(.some(cache)) where cachePolicy.validate(cache.timestamp, against: self.currentDate()):
                let output = self.mapper(cache)
                completion(.success(output))

            case .success:
                completion(.success([]))
            }
        }
    }
}

public extension LocalLoader {
    typealias ValidationResult = Result<Void, Error>

    func validateCache(completion: @escaping (ValidationResult) -> Void) {
        store.retrieve { [weak self, cachePolicy] result in
            guard let self = self else { return }

            switch result {
            case .failure:
                self.store.deleteCached(completion: completion)

            case let .success(.some(cache)) where !cachePolicy.validate(cache.timestamp, against: self.currentDate()):
                self.store.deleteCached(completion: completion)

            case .success:
                completion(.success(()))
            }
        }
    }
}
