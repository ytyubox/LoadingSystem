//
/*
 *		Created by 游宗諭 in 2021/3/12
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 11.2
 */

import Foundation
public struct ErrorViewModel {
    public let message: String?

    public static var noError: ErrorViewModel {
        return ErrorViewModel(message: nil)
    }

    public static func error(message: String) -> ErrorViewModel {
        return ErrorViewModel(message: message)
    }
}
