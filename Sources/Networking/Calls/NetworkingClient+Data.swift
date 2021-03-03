import Foundation
import RxSwift

public extension NetworkingClient {
    
    func get(_ route: String, params: Params = Params()) -> Single<Data> {
        request(.get, route, params: params).observable()
    }
    
    func post(_ route: String, params: Params = Params()) -> Single<Data> {
        request(.post, route, params: params).observable()
    }
    
    func put(_ route: String, params: Params = Params()) -> Single<Data> {
        request(.put, route, params: params).observable()
    }
    
    func patch(_ route: String, params: Params = Params()) -> Single<Data> {
        request(.patch, route, params: params).observable()
    }
    
    func delete(_ route: String, params: Params = Params()) -> Single<Data> {
        request(.delete, route, params: params).observable()
    }
}
