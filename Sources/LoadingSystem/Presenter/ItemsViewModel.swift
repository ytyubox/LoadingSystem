//
/* 
 *		Created by 游宗諭 in 2021/3/12
 *		
 *		Using Swift 5.0
 *		
 *		Running on macOS 11.2
 */


import Foundation

public struct ItemsViewModel<Item> {
    public let items: [Item]
    
    public init(items: [Item]) {
        self.items = items
    }
}

public struct LoadingViewModel {
    public let isLoading: Bool
}

