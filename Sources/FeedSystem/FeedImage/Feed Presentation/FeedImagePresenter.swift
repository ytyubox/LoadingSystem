import Foundation
import LoadingSystem

public protocol FeedImageView: UniversalView where Union == FeedImageViewModel<Image> {
    associatedtype Image
}

public final class FeedImagePresenter<View: FeedImageView, Image>:UniversalPresenter<View, FeedImage, FeedImageViewModel<Image>> where View.Image == Image {
    
    
    public init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        super.init(
            view: view,
            LoadingTransformer: FeedImageViewModelMapper.loading(for: ),
            SuccessTransformer: {
                (input, data) in
                FeedImageViewModelMapper.success(with: data, imageTransformer: imageTransformer, for: input)
            },
            FailureTransformer: {
                (input, error) in
                FeedImageViewModelMapper.failure(input, with: error)
            })
    }
}

