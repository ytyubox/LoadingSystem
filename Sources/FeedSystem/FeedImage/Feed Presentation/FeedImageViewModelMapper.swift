//
/* 
 *		Created by 游宗諭 in 2021/3/12
 *		
 *		Using Swift 5.0
 *		
 *		Running on macOS 11.2
 */


import Foundation
enum FeedImageViewModelMapper<Image> {
    static func failure(_ model: FeedImage, with error:Error) -> FeedImageViewModel<Image> {
        FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: false,
            shouldRetry: true
        )
    }
    static func loading(for model: FeedImage) -> FeedImageViewModel<Image> {
        FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: true,
            shouldRetry: false
        )
    }
    
    static func success(
        with data: Data,
        imageTransformer: (Data) -> Image?,
        for model: FeedImage) -> FeedImageViewModel<Image> {
        let image = imageTransformer(data)
        return FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: image,
            isLoading: false,
            shouldRetry: image == nil
        )
    }
}
