//
/*
 *		Created by 游宗諭 in 2021/3/12
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 11.2
 */

import Foundation

public protocol UniversalView {
    associatedtype Union

    func display(_ model: Union)
}

open class UniversalPresenter<View: UniversalView, Input, Output> where View.Union == Output {
    private let view: View
    private let loadingTransformer: (Input) -> Output
    private let successTransformer: (Input, Data) throws -> Output
    private let successCaseFailureTransformer: ((Input, Error) -> Output)?
    private let failureTransformer: (Input, Error) -> Output

    public init(view: View,
                LoadingTransformer: @escaping (Input) -> Output,
                SuccessTransformer: @escaping (Input, Data) throws -> Output,
                successCaseFailureTransformer: ((Input, Error) -> Output)? = nil,
                FailureTransformer: @escaping (Input, Error) -> Output)
    {
        self.view = view
        loadingTransformer = LoadingTransformer
        successTransformer = SuccessTransformer
        self.successCaseFailureTransformer = successCaseFailureTransformer
        failureTransformer = FailureTransformer
    }

    public func didStartLoadingImageData(for model: Input) {
        let loading = loadingTransformer(model)
        view.display(loading)
    }

    public func didFinishLoadingImageData(with data: Data, for model: Input) {
        do {
            let success = try successTransformer(model, data)
            view.display(success)
        } catch {
            if let fromSuccessCase = successCaseFailureTransformer?(model, error) {
                view.display(fromSuccessCase)
            }
        }
    }

    public func didFinishLoadingImageData(with error: Error, for model: Input) {
        let failure = failureTransformer(model, error)
        view.display(failure)
    }
}
