import Foundation

public protocol ItemCache {
    typealias Result = Swift.Result<Void, Error>
    associatedtype Item
    func save(_ item: [Item], completion: @escaping (Result) -> Void)
}

public protocol AModel {
    associatedtype Local
    var local: Local { get }
}

public protocol RemoteModel {
    associatedtype Model: AModel
    var model: Model { get }
}

public protocol LocalModel {
    associatedtype Model: AModel
    var model: Model { get }
}

public extension Array where Element: AModel {
    func toLocals() -> [Element.Local] {
        map(\.local)
    }
}

public extension Array where Element: LocalModel {
    func toModels() -> [Element.Model] {
        map(\.model)
    }
}

public extension Array where Element: RemoteModel {
    func toModels() -> [Element.Model] {
        map(\.model)
    }
}
