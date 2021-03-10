import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    public var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
