import Foundation

public final class RemoteDataLoader: CancelableLoaderOwner {
    public typealias CancelableOutput = Data
    public let client: HTTPClient
    public let mapper: Mapper
    public init(client: HTTPClient,
                mapper: @escaping Mapper = { data, response in
                    try throwIfNot200(response)
                    return try data.throwIfEmpty()
                })
    {
        self.client = client
        self.mapper = mapper
    }

    public typealias Error = RemoteError
}

public func throwIfNot200(_ response: HTTPURLResponse) throws {
    guard response.statusCode == 200 else {
        throw RemoteError.invalidData
    }
}

public extension Data {
    func throwIfEmpty() throws -> Data {
        if isEmpty {
            throw RemoteError.invalidData
        }
        return self
    }
}
