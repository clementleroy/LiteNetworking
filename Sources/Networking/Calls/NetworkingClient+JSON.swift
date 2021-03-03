import Foundation
import RxSwift

public extension NetworkingClient {
    
    func get(_ route: String, params: Params = Params()) -> Single<Any> {
        get(route, params: params).toJSON()
    }
    
    func post(_ route: String, params: Params = Params()) -> Single<Any> {
        post(route, params: params).toJSON()
    }
    
    func put(_ route: String, params: Params = Params()) -> Single<Any> {
        put(route, params: params).toJSON()
    }
    
    func patch(_ route: String, params: Params = Params()) -> Single<Any> {
        patch(route, params: params).toJSON()
    }
    
    func delete(_ route: String, params: Params = Params()) -> Single<Any> {
        delete(route, params: params).toJSON()
    }
    
}

// Data to JSON
extension PrimitiveSequence where Trait == SingleTrait, Element == Data {

    public func toJSON() -> Single<Any> {
        map { data -> Any in
            try JSONSerialization.jsonObject(with: data, options: [])
        }
    }
    
}
