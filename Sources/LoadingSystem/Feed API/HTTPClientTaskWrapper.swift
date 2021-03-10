//
/*
 *		Created by 游宗諭 in 2021/3/10
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 11.2
 */
import Foundation

public final class HTTPClientTaskWrapper<Output>: CancellabelTask {
    public typealias Outcome = Result<Output, Error>
    private var completion: ((Outcome) -> Void)?

    public var wrapped: HTTPClientTask?

    public init(_ completion: @escaping (Outcome) -> Void) {
        self.completion = completion
    }

    public convenience init(_ completion: @escaping (Outcome) -> Void,
                            wrappedFactory: (HTTPClientTaskWrapper) -> HTTPClientTask)
    {
        self.init(completion)
        wrapped = wrappedFactory(self)
    }

    public convenience init(_ completion: @escaping (Outcome) -> Void, wrapped: HTTPClientTask) {
        self.init(completion)
        self.wrapped = wrapped
    }

    public func complete(with result: Outcome) {
        completion?(result)
    }

    public func cancel() {
        preventFurtherCompletions()
        wrapped?.cancel()
    }

    private func preventFurtherCompletions() {
        completion = nil
    }
}
