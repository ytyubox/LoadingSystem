//
/*
 *		Created by 游宗諭 in 2021/3/12
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 11.2
 */

import Foundation

private class LoaderBaseBox<Output>: Loader {
    init() {}
    func load(completion _: @escaping Promise) {
        fatalError()
    }
}

private final class LoaderBox<LoaderType: Loader>: LoaderBaseBox<LoaderType.Output> {
    let base: LoaderType
    init(base: LoaderType) {
        self.base = base
        super.init()
    }

    override func load(completion: @escaping Promise) {
        base.load(completion: completion)
    }
}

public struct AnyLoader<Output>: Loader {
    private let box: LoaderBaseBox<Output>

    public init<F: Loader>(_ future: F) where Output == F.Output {
        if let earsed = future as? AnyLoader<Output> {
            box = earsed.box
        } else {
            box = LoaderBox(base: future)
        }
    }

    public func load(completion: @escaping Promise) {
        box.load(completion: completion)
    }
}

public extension Loader {
    func toAnyLoader() -> AnyLoader<Output> {
        AnyLoader(self)
    }
}
