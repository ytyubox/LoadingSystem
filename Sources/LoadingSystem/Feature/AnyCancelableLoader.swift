//
/*
 *		Created by 游宗諭 in 2021/3/12
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 11.2
 */

import Foundation

private class CancellableLoaderBaseBox<CancellableOutput>: CancellableLoader {
    func load(from _: URL, completion _: @escaping Promise) -> CancellabelTask {
        fatalError()
    }

    init() {}
}

private final class CancellableLoaderBox<CancellableLoaderType: CancellableLoader>: CancellableLoaderBaseBox<CancellableLoaderType.CancellableOutput> {
    let base: CancellableLoaderType
    init(base: CancellableLoaderType) {
        self.base = base
        super.init()
    }

    override func load(from url: URL, completion: @escaping Promise) -> CancellabelTask {
        base.load(from: url, completion: completion)
    }
}

public struct AnyCancellableLoader<CancellableOutput>: CancellableLoader {
    private let box: CancellableLoaderBaseBox<CancellableOutput>

    public init<F: CancellableLoader>(_ future: F) where CancellableOutput == F.CancellableOutput {
        if let earsed = future as? AnyCancellableLoader<CancellableOutput> {
            box = earsed.box
        } else {
            box = CancellableLoaderBox(base: future)
        }
    }

    public func load(from url: URL, completion: @escaping Promise) -> CancellabelTask {
        box.load(from: url, completion: completion)
    }
}

public extension CancellableLoader {
    func toAnyCancellableLoader() -> AnyCancellableLoader<CancellableOutput> {
        AnyCancellableLoader(self)
    }
}
