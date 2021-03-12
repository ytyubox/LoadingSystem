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
    func display<Item>(_ viewModel: ItemsViewModel<Item>)
}

public protocol LoadingView {
    func display(_ viewModel: LoadingViewModel)
}

public protocol ErrorView {
    func display(_ viewModel: ErrorViewModel)
}

open class Presenter<Item> {
    private let feedView: ItemsView
    private let loadingView: LoadingView
    private let errorView: ErrorView
    private let errorMessageFactory: (Error) -> String


    public init(feedView: ItemsView,
                loadingView: LoadingView,
                errorView: ErrorView,
                errorMessageFactory: @escaping (Error) -> String
    ) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
        self.errorMessageFactory = errorMessageFactory
    }


    public func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(LoadingViewModel(isLoading: true))
    }

    public func didFinishLoadingFeed(with items: [Item]) {
        feedView.display(ItemsViewModel(items: items))
        loadingView.display(LoadingViewModel(isLoading: false))
    }

    public func didFinishLoadingFeed(with error: Error) {
        let message = errorMessageFactory(error)
        errorView.display(.error(message: message))
        loadingView.display(LoadingViewModel(isLoading: false))
    }
}
