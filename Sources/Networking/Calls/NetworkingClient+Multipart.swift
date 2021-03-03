import Foundation
import RxSwift

public extension NetworkingClient {
    
    func post(_ route: String,
              params: Params = Params(),
              multipartData: MultipartData) -> Observable<(Data?, Progress)> {
        return post(route, params: params, multipartData: [multipartData])
    }
    
    func put(_ route: String,
             params: Params = Params(),
             multipartData: MultipartData) -> Observable<(Data?, Progress)> {
        return put(route, params: params, multipartData: [multipartData])
    }
    
    func patch(_ route: String,
               params: Params = Params(),
               multipartData: MultipartData) -> Observable<(Data?, Progress)> {
        return patch(route, params: params, multipartData: [multipartData])
    }
    
    // Allow multiple multipart data
    func post(_ route: String,
              params: Params = Params(),
              multipartData: [MultipartData]) -> Observable<(Data?, Progress)> {
        let req = request(.post, route, params: params)
        req.multipartData = multipartData
        return req.uploadObservable()
    }
    
    func put(_ route: String,
             params: Params = Params(),
             multipartData: [MultipartData]) -> Observable<(Data?, Progress)> {
        let req = request(.put, route, params: params)
        req.multipartData = multipartData
        return req.uploadObservable()
    }
    
    func patch(_ route: String,
               params: Params = Params(),
               multipartData: [MultipartData]) -> Observable<(Data?, Progress)> {
        let req = request(.patch, route, params: params)
        req.multipartData = multipartData
        return req.uploadObservable()
    }
}
