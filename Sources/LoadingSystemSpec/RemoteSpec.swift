//
/*
 *		Created by 游宗諭 in 2021/3/24
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 11.2
 */

#if canImport(XCTest)
    public protocol LoadFromRemoteUseCaseSpec {
        func test_init_doesNotRequestDataFromURL()

        func test_load_requestsDataFromURL()

        func test_loadTwice_requestsDataFromURLTwice()

        func test_load_deliversErrorOnClientError()

        func test_load_deliversErrorOnNon200HTTPResponse()

        func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON()

        func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList()

        func test_load_deliversItemsOn200HTTPResponseWithJSONItems()

        func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated()
    }

#endif
