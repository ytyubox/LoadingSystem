//
/*
 *		Created by 游宗諭 in 2021/3/24
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 11.2
 */

import Foundation
public protocol LoadFromCacheUseCaseSpec {
    func test_init_doesNotMessageStoreUponCreation()

    func test_load_requestsCacheRetrieval()

    func test_load_failsOnRetrievalError()

    func test_load_deliversNoItemsOnEmptyCache()

    func test_load_deliversCachedItemsOnNonExpiredCache()

    func test_load_deliversNoItemsOnCacheExpiration()

    func test_load_deliversNoItemsOnExpiredCache()

    func test_load_hasNoSideEffectsOnRetrievalError()

    func test_load_hasNoSideEffectsOnEmptyCache()

    func test_load_hasNoSideEffectsOnNonExpiredCache()

    func test_load_hasNoSideEffectsOnCacheExpiration()

    func test_load_hasNoSideEffectsOnExpiredCache()

    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated()
}
