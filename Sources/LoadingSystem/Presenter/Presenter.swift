//
/* 
 *		Created by 游宗諭 in 2021/3/12
 *		
 *		Using Swift 5.0
 *		
 *		Running on macOS 11.2
 */


import Foundation

public protocol ItemsView {
    associatedtype Item
    func display(_ viewModel: ItemsViewModel<Item>)
}

public protocol LoadingView {
    func display(_ viewModel: LoadingViewModel)
}

public protocol ErrorView {
    func display(_ viewModel: ErrorViewModel)
}

open class Presenter<Item, DisplayView> where DisplayView:ItemsView, DisplayView.Item == Item {
    private let itemsView: DisplayView
    private let loadingView: LoadingView
    private let errorView: ErrorView
    private let errorMessageFactory: (Error) -> String


    public init(itemsView: DisplayView,
                loadingView: LoadingView,
                errorView: ErrorView,
                errorMessageFactory: @escaping (Error) -> String
    ) {
        self.itemsView = itemsView
        self.loadingView = loadingView
        self.errorView = errorView
        self.errorMessageFactory = errorMessageFactory
    }


     public func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(LoadingViewModel(isLoading: true))
    }

    public func didFinishLoading(with items: [Item]) {
        itemsView.display(ItemsViewModel(items: items))
        loadingView.display(LoadingViewModel(isLoading: false))
    }

    public func didFinishLoading(with error: Error) {
        let message = errorMessageFactory(error)
        errorView.display(.error(message: message))
        loadingView.display(LoadingViewModel(isLoading: false))
    }
}
