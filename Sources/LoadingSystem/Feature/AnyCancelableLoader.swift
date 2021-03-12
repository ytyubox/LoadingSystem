//
/* 
 *		Created by 游宗諭 in 2021/3/12
 *		
 *		Using Swift 5.0
 *		
 *		Running on macOS 11.2
 */


import Foundation


private class CancelableLoaderBaseBox<CancelableOutput>: CancelableLoader {
    func load(from url: URL, completion: @escaping Promise) -> CancellabelTask {
        fatalError()
    }

    init() {}
   
}

private final class CancelableLoaderBox<FeedCancelableLoaderType: CancelableLoader>: CancelableLoaderBaseBox<FeedCancelableLoaderType.CancelableOutput> {
    let base: FeedCancelableLoaderType
    init(base: FeedCancelableLoaderType) {
        self.base = base
        super.init()
    }
    override func load(from url: URL, completion: @escaping Promise) -> CancellabelTask {
        base.load(from: url, completion: completion)
    }
}

public struct AnyCancelableLoader<CancelableOutput>: CancelableLoader {
    private let box: CancelableLoaderBaseBox<CancelableOutput>

    public init<F: CancelableLoader>(_ future: F) where CancelableOutput == F.CancelableOutput {
        if let earsed = future as? AnyCancelableLoader<CancelableOutput> {
            box = earsed.box
        } else {
            box = CancelableLoaderBox(base: future)
        }
    }
    public func load(from url: URL, completion: @escaping Promise) -> CancellabelTask {
        box.load(from: url, completion: completion)
    }
}

public extension CancelableLoader {
    func toAnyCancelableLoader() -> AnyCancelableLoader<CancelableOutput> {
        AnyCancelableLoader(self)
    }
}
