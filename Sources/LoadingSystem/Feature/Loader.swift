import Foundation

public protocol Loader {
    associatedtype Output
    typealias Outcome = Swift.Result<Output, Error>
    typealias Promise = (Outcome) -> Void

    func load(completion: @escaping Promise)
}

public protocol ItemsLoader: Loader where Output: ExpressibleByArrayLiteral {}
