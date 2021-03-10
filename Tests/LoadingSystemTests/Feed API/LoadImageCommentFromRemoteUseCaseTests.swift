//
/*
 *		Created by 游宗諭 in 2021/2/4
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 10.15
 */

import LoadingSystem
import XCTest

class LoadImageCommentFromRemoteUseCaseTests: XCTestCase {
    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_loadImageDataFromURL_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT()

        _ = sut.load(from: url) { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT()

        _ = sut.load(from: url) { _ in }
        _ = sut.load(from: url) { _ in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_loadImageDataFromURL_deliversInvalidDataErrorOnNon2xxHTTPResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 300, 400, 500]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.complete(withStatusCode: code, data: anyData(), at: index)
            })
        }
    }

    func test_loadImageComment_deliversNoItemsOn2xxHTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        let samples = [200, 250, 299]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success([]), when: {
                let emptyListJSON = makeItemsJSON([])
                client.complete(withStatusCode: code, data: emptyListJSON, at: index)
            })
        }
    }

    func test_loadImageComment_deliversItemsOn2xxHTTPResponseWithJSONItems() throws {
        let (sut, client) = makeSUT()
        let samples = [200, 250, 299]

        let item1 = try makeItem(
            id: anyUUID(),
            message: "a message",
            createdAt: "2020-05-20T11:24:59+0000",
            authorName: "a username"
        )

        let item2 = try makeItem(
            id: anyUUID(),
            message: "another message",
            createdAt: "2020-05-19T14:23:53+0000",
            authorName: "another username"
        )

        let items = [item1.model, item2.model]
        let jsons = [item1.json, item2.json]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success(items), when: {
                let emptyListJSON = makeItemsJSON(jsons)
                client.complete(withStatusCode: code, data: emptyListJSON, at: index)
            })
        }
    }

    func test_loadImageDataFromURL_deliversInvalidDataErrorOn2xxHTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let emptyData = Data()
            client.complete(withStatusCode: 200, data: emptyData)
        })
    }

    func test_loadImageData_deliversErrorOn2xxHTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }

    func test_cancelLoadImageDataURLTask_cancelsClientURLRequest() {
        let (sut, client) = makeSUT()
        let url = URL(string: "https://a-given-url.com")!

        let task = sut.load(from: url) { _ in }
        XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL request until task is cancelled")

        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")
    }

    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let (sut, client) = makeSUT()
        let nonEmptyData = Data("non-empty data".utf8)

        var received = [RemoteImageCommentLoader.Outcome]()
        let task = sut.load(from: anyURL()) { received.append($0) }
        task.cancel()

        client.complete(withStatusCode: 404, data: anyData())
        client.complete(withStatusCode: 200, data: nonEmptyData)
        client.complete(with: anyNSError())

        XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
    }

    func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteImageCommentLoader? = RemoteImageCommentLoader(client: client)

        var capturedResults = [RemoteImageCommentLoader.Outcome]()
        _ = sut?.load(from: anyURL()) { capturedResults.append($0) }

        sut = nil
        client.complete(withStatusCode: 200, data: anyData())

        XCTAssertTrue(capturedResults.isEmpty)
    }

    // MARK: - helper

    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (RemoteImageCommentLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentLoader(client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }

    private func failure(_ error: RemoteError) -> RemoteImageCommentLoader.Outcome {
        return .failure(error)
    }

    private func makeItem(id: String, message: String, createdAt: String, authorName: String) throws -> (model: ImageComment, json: [String: Any]) {
        let id = try XCTUnwrap(UUID(uuidString: id), "failure to generate UUID form id: \(id)")
        let createdAtDate = try dateStringToDate(createdAt)
        let item = ImageComment(id: id, message: message, createdAt: createdAtDate, author: .init(username: authorName))

        let json: [String: Any] = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt,
            "author": [
                "username": authorName,
            ],
        ]

        return (item, json)
    }

    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }

    private func expect(_ sut: RemoteImageCommentLoader, toCompleteWith expectedResult: RemoteImageCommentLoader.Outcome, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let url = URL(string: "https://a-given-url.com")!
        let exp = expectation(description: "Wait for load completion")

        _ = sut.load(from: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedComment), .success(expectedComment)):
                XCTAssertEqual(receivedComment, expectedComment, file: file, line: line)

            case let (.failure(receivedError as RemoteDataLoader.Error), .failure(expectedError as RemoteDataLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result\n\(expectedResult)\ngot\n\(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }
}
