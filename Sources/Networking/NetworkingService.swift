import Foundation
import RxSwift

public protocol NetworkingService {
    var network: NetworkingClient { get }
}

// Sugar, just forward calls to underlying network client

public extension NetworkingService {
    
    // Data
    
    func get(_ route: String, params: Params = Params()) -> Single<Data> {
        network.get(route, params: params)
    }
    
    func post(_ route: String, params: Params = Params()) -> Single<Data> {
        network.post(route, params: params)
    }
    
    func put(_ route: String, params: Params = Params()) -> Single<Data> {
        network.put(route, params: params)
    }
    
    func patch(_ route: String, params: Params = Params()) -> Single<Data> {
        network.patch(route, params: params)
    }
    
    func delete(_ route: String, params: Params = Params()) -> Single<Data> {
        network.delete(route, params: params)
    }
    
    // Void
    
    func get(_ route: String, params: Params = Params()) -> Completable {
        network.get(route, params: params)
    }
    
    func post(_ route: String, params: Params = Params()) -> Completable {
        network.post(route, params: params)
    }
    
    func put(_ route: String, params: Params = Params()) -> Completable {
        network.put(route, params: params)
    }
    
    func patch(_ route: String, params: Params = Params()) -> Completable {
        network.patch(route, params: params)
    }
    
    func delete(_ route: String, params: Params = Params()) -> Completable {
        network.delete(route, params: params)
    }
    
    // JSON
    
    func get(_ route: String, params: Params = Params()) -> Single<Any> {
        network.get(route, params: params)
    }
    
    func post(_ route: String, params: Params = Params()) -> Single<Any> {
        network.post(route, params: params)
    }
    
    func put(_ route: String, params: Params = Params()) -> Single<Any> {
        network.put(route, params: params)
    }
    
    func patch(_ route: String, params: Params = Params()) -> Single<Any> {
        network.patch(route, params: params)
    }
    
    func delete(_ route: String, params: Params = Params()) -> Single<Any> {
        network.delete(route, params: params)
    }
    
    // NetworkingJSONDecodable
    
    func get<T: NetworkingJSONDecodable>(_ route: String,
                                         params: Params = Params(),
                                         keypath: String? = nil) -> Single<T> {
        return get(route, params: params)
            .map { json -> T in try NetworkingParser().toModel(json, keypath: keypath) }
            .observeOn(MainScheduler.asyncInstance)
    }
    
    func post<T: NetworkingJSONDecodable>(_ route: String,
                                          params: Params = Params(),
                                          keypath: String? = nil) -> Single<T> {
        network.post(route, params: params, keypath: keypath)
    }
    
    func put<T: NetworkingJSONDecodable>(_ route: String,
                                         params: Params = Params(),
                                         keypath: String? = nil) -> Single<T> {
        network.put(route, params: params, keypath: keypath)
    }
    
    func patch<T: NetworkingJSONDecodable>(_ route: String,
                                           params: Params = Params(),
                                           keypath: String? = nil) -> Single<T> {
        network.patch(route, params: params, keypath: keypath)
    }
    
    func delete<T: NetworkingJSONDecodable>(_ route: String,
                                            params: Params = Params(),
                                            keypath: String? = nil) -> Single<T> {
        network.delete(route, params: params, keypath: keypath)
    }
    
    // Array version
    func get<T: NetworkingJSONDecodable>(_ route: String,
                                         params: Params = Params(),
                                         keypath: String? = nil) -> Single<[T]> {
        network.get(route, params: params, keypath: keypath)
    }
}
