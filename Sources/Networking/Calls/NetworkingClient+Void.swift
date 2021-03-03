import Foundation
import RxSwift

public extension NetworkingClient {
    
    func get(_ route: String, params: Params = Params()) -> Completable {
        let request: Single<Data> = get(route, params: params)
        return request.asCompletable()
    }
    
    func post(_ route: String, params: Params = Params()) -> Completable {
        let request: Single<Data> = post(route, params: params)
        return request.asCompletable()
    }
    
    func put(_ route: String, params: Params = Params()) -> Completable {
        let request: Single<Data> = put(route, params: params)
        return request.asCompletable()
    }
    
    func patch(_ route: String, params: Params = Params()) -> Completable {
        let request: Single<Data> = patch(route, params: params)
        return request.asCompletable()
    }
    
    func delete(_ route: String, params: Params = Params()) -> Completable {
        let request: Single<Data> = delete(route, params: params)
        return request.asCompletable()
    }
}
