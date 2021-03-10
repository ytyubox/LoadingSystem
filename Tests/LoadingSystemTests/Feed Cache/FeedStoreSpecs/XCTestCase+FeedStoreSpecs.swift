

import FeedSystem
import LoadingSystem
import XCTest

extension FeedStoreSpecs where Self: XCTestCase {
    typealias Local = LocalFeedImage
    typealias RetrievalResult = Result<CachedFeed<Local>?, Error>
    func assertThatRetrieveDeliversEmptyOnEmptyCache<SUT: Store>(on sut: SUT, file: StaticString = #filePath, line: UInt = #line) where SUT.Local == Local {
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }

    func assertThatRetrieveHasNoSideEffectsOnEmptyCache<SUT: Store>(on sut: SUT, file: StaticString = #filePath, line: UInt = #line) where SUT.Local == Local {
        expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
    }

    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache<SUT: Store>(on sut: SUT, file: StaticString = #filePath, line: UInt = #line) where SUT.Local == Local {
        let feed = uniqueImageFeed().local
        let timestamp = Date()

        insert((feed, timestamp), to: sut)

        expect(sut, toRetrieve: .success(CachedFeed(feed: feed, timestamp: timestamp)), file: file, line: line)
    }

    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache<SUT: Store>(on sut: SUT, file: StaticString = #filePath, line: UInt = #line) where SUT.Local == Local {
        let feed = uniqueImageFeed().local
        let timestamp = Date()

        insert((feed, timestamp), to: sut)

        expect(sut, toRetrieveTwice: .success(CachedFeed(feed: feed, timestamp: timestamp)), file: file, line: line)
    }

    func assertThatInsertDeliversNoErrorOnEmptyCache<SUT: Store>(on sut: SUT, file: StaticString = #filePath, line: UInt = #line) where SUT.Local == Local {
        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)

        XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
    }

    func assertThatInsertDeliversNoErrorOnNonEmptyCache<SUT: Store>(on sut: SUT, file: StaticString = #filePath, line: UInt = #line) where SUT.Local == Local {
        insert((uniqueImageFeed().local, Date()), to: sut)

        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)

        XCTAssertNil(insertionError, "Expected to override cache successfully", file: file, line: line)
    }

    func assertThatInsertOverridesPreviouslyInsertedCacheValues<SUT: Store>(on sut: SUT, file: StaticString = #filePath, line: UInt = #line) where SUT.Local == Local {
        insert((uniqueImageFeed().local, Date()), to: sut)

        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        insert((latestFeed, latestTimestamp), to: sut)

        expect(sut, toRetrieve: .success(CachedFeed(feed: latestFeed, timestamp: latestTimestamp)), file: file, line: line)
    }

    func assertThatDeleteDeliversNoErrorOnEmptyCache<SUT: Store>(on sut: SUT, file: StaticString = #filePath, line: UInt = #line) {
        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
    }

    func assertThatDeleteHasNoSideEffectsOnEmptyCache<SUT: Store>(on sut: SUT, file: StaticString = #filePath, line: UInt = #line) where SUT.Local == Local {
        deleteCache(from: sut)

        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }

    func assertThatDeleteDeliversNoErrorOnNonEmptyCache<SUT: Store>(on sut: SUT, file: StaticString = #filePath, line: UInt = #line) where SUT.Local == Local {
        insert((uniqueImageFeed().local, Date()), to: sut)

        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
    }

    func assertThatDeleteEmptiesPreviouslyInsertedCache<SUT: Store>(on sut: SUT, file: StaticString = #filePath, line: UInt = #line) where SUT.Local == Local {
        insert((uniqueImageFeed().local, Date()), to: sut)

        deleteCache(from: sut)

        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }

    func assertThatSideEffectsRunSerially<SUT: Store>(on sut: SUT, file: StaticString = #filePath, line: UInt = #line) where SUT.Local == LocalFeedImage {
        var completedOperationsInOrder = [XCTestExpectation]()

        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        }

        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed { _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        }

        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        }

        waitForExpectations(timeout: 5.0)

        XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order", file: file, line: line)
    }
}

extension FeedStoreSpecs where Self: XCTestCase {
    @discardableResult
    func insert<SUT: Store>(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: SUT) -> Error? where SUT.Local == LocalFeedImage {
        let exp = expectation(description: "Wait for cache insertion")
        var insertionError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { result in
            if case let Result.failure(error) = result { insertionError = error }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }

    @discardableResult
    func deleteCache<SUT: Store>(from sut: SUT) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?
        sut.deleteCachedFeed { result in
            if case let Result.failure(error) = result { deletionError = error }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }

    func expect<SUT: Store>(_ sut: SUT, toRetrieveTwice expectedResult: RetrievalResult, file: StaticString = #filePath, line: UInt = #line) where SUT.Local == Local {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }

    func expect<SUT: Store>(_ sut: SUT, toRetrieve expectedResult: RetrievalResult, file: StaticString = #filePath, line: UInt = #line) where SUT.Local == Local {
        let exp = expectation(description: "Wait for cache retrieval")

        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.success(.none), .success(.none)),
                 (.failure, .failure):
                break

            case let (.success(.some(expected)), .success(.some(retrieved))):
                XCTAssertEqual(retrieved.feed, expected.feed, file: file, line: line)
                XCTAssertEqual(retrieved.timestamp, expected.timestamp, file: file, line: line)

            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
}
