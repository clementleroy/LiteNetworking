import Foundation
import RxSwift


public protocol NetworkingJSONDecodable {
    /// The method you declare your JSON mapping in.
    static func decode(_ json: Any) throws -> Self
}

public extension NetworkingClient {
    
    func get<T: NetworkingJSONDecodable>(_ route: String,
                                         params: Params = Params(),
                                         keypath: String? = nil) -> Single<T> {
        get(route, params: params)
            .map { json -> T in
                try NetworkingParser().toModel(json, keypath: keypath)
            }
            .observe(on: MainScheduler.asyncInstance)
    }
    
    // Array version
    func get<T: NetworkingJSONDecodable>(_ route: String,
                                         params: Params = Params(),
                                         keypath: String? = nil) -> Single<[T]> {
        let keypath = keypath ?? defaultCollectionParsingKeyPath
        return get(route, params: params)
            .map { json -> [T] in
                try NetworkingParser().toModels(json, keypath: keypath)
            }
            .observe(on: MainScheduler.asyncInstance)
    }
    
    func post<T: NetworkingJSONDecodable>(_ route: String,
                                          params: Params = Params(),
                                          keypath: String? = nil) -> Single<T> {
        return post(route, params: params)
            .map { json -> T in
                try NetworkingParser().toModel(json, keypath: keypath)
            }
            .observe(on: MainScheduler.asyncInstance)
    }
    
    func put<T: NetworkingJSONDecodable>(_ route: String,
                                         params: Params = Params(),
                                         keypath: String? = nil) -> Single<T> {
        return put(route, params: params)
            .map { json -> T in
                try NetworkingParser().toModel(json, keypath: keypath)
            }
            .observe(on: MainScheduler.asyncInstance)
    }
    
    func patch<T: NetworkingJSONDecodable>(_ route: String,
                                           params: Params = Params(),
                                           keypath: String? = nil) -> Single<T> {
        return patch(route, params: params)
            .map { json -> T in try NetworkingParser().toModel(json, keypath: keypath) }
            .observe(on: MainScheduler.asyncInstance)
    }
    
    func delete<T: NetworkingJSONDecodable>(_ route: String,
                                            params: Params = Params(),
                                            keypath: String? = nil) -> Single<T> {
        return delete(route, params: params)
            .map { json -> T in try NetworkingParser().toModel(json, keypath: keypath) }
            .observe(on: MainScheduler.asyncInstance)
    }
}

// Provide default implementation for Decodable models.
public extension NetworkingJSONDecodable where Self: Decodable {
    
    static func decode(_ json: Any) throws -> Self {
        let decoder = JSONDecoder()
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        let model = try decoder.decode(Self.self, from: data)
        return model
    }
}
