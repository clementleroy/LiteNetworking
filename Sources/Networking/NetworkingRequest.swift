import Foundation
import RxSwift
import RxCocoa

public class NetworkingRequest: NSObject {
    
    var parameterEncoding = ParameterEncoding.urlEncoded
    var baseURL = ""
    var route = ""
    var httpVerb = HTTPVerb.get
    public var params = Params()
    var headers = [String: String]()
    var multipartData: [MultipartData]?
    var logLevels: NetworkingLogLevel {
        get { return logger.logLevels }
        set { logger.logLevels = newValue }
    }
    private let logger = NetworkingLogger()
    var timeout: TimeInterval?
    let progressSubject = PublishSubject<Progress>()
    
    public func uploadObservable() -> Observable<(Data?, Progress)> {
        guard let urlRequest = buildURLRequest() else {
            return .error(NetworkingError.unableToParseRequest)
        }
        logger.log(request: urlRequest)
        
        let config = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        let callObservable: Observable<(Data?, Progress)> = urlSession.rx.response(request: urlRequest)
            .map { response, data -> Data in
                self.logger.log(response: response, data: data)
                if !(200...299 ~= response.statusCode) {
                    var error = NetworkingError(errorCode: response.statusCode)
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                        error.jsonPayload = json
                    }
                    throw error
                }
                return data
            }
            .catchError { error  in
                .error(NetworkingError(error: error))
            }
            .observeOn(MainScheduler.asyncInstance)
            .map { data -> (Data?, Progress) in
                return (data, Progress())
            }
        
        let progressObservable: Observable<(Data?, Progress)> = progressSubject
            .map { progress -> (Data?, Progress) in
                (nil, progress)
            }
        
        return Observable.merge(callObservable, progressObservable)
            .observeOn(MainScheduler.asyncInstance)
    }
    
    public func observable() -> Single<Data> {
        guard let urlRequest = buildURLRequest() else {
            return .error(NetworkingError.unableToParseRequest)
        }
        logger.log(request: urlRequest)
        
        let config = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        return urlSession.rx.response(request: urlRequest)
            .map { response, data -> Data in
                self.logger.log(response: response, data: data)
                if !(200...299 ~= response.statusCode) {
                    var error = NetworkingError(errorCode: response.statusCode)
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                        error.jsonPayload = json
                    }
                    throw error
                }
                return data
            }
            .take(1)
            .asSingle()
            .catchError { error -> Single<Data> in
                Single.error(NetworkingError(error: error))
            }
            .observeOn(MainScheduler.asyncInstance)
    }
    
    private func getURLWithParams() -> String {
        let urlString = baseURL + route
        guard let url = URL(string: urlString) else {
            return urlString
        }
        
        if var urlComponents = URLComponents(url: url ,resolvingAgainstBaseURL: false) {
            var queryItems = urlComponents.queryItems ?? [URLQueryItem]()
            params.forEach { param in
                // arrayParam[] syntax
                if let array = param.value as? [CustomStringConvertible] {
                    array.forEach {
                        queryItems.append(URLQueryItem(name: "\(param.key)[]", value: "\($0)"))
                    }
                }
                queryItems.append(URLQueryItem(name: param.key, value: "\(param.value)"))
            }
            urlComponents.queryItems = queryItems
            return urlComponents.url?.absoluteString ?? urlString
        }
        return urlString
    }
    
    internal func buildURLRequest() -> URLRequest? {
        var urlString = baseURL + route
        if httpVerb == .get {
            urlString = getURLWithParams()
        }
        
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        
        if httpVerb != .get && multipartData == nil {
            switch parameterEncoding {
            case .urlEncoded:
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            case .json:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        
        request.httpMethod = httpVerb.rawValue
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let timeout = timeout {
            request.timeoutInterval = timeout
        }
        
        if httpVerb != .get && multipartData == nil {
            switch parameterEncoding {
            case .urlEncoded:
                request.httpBody = percentEncodedString().data(using: .utf8)
            case .json:
                let jsonData = try? JSONSerialization.data(withJSONObject: params)
                request.httpBody = jsonData
            }
        }
        
        // Multipart
        if let multiparts = multipartData {
            // Construct a unique boundary to separate values
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.httpBody = buildMultipartHttpBody(params: params, multiparts: multiparts, boundary: boundary)
        }
        return request
    }
    
    private func buildMultipartHttpBody(params: Params, multiparts: [MultipartData], boundary: String) -> Data {
        // Combine all multiparts together
        let allMultiparts: [HttpBodyConvertible] = [params] + multiparts
        let boundaryEnding = "--\(boundary)--".data(using: .utf8)!
        
        // Convert multiparts to boundary-seperated Data and combine them
        return allMultiparts
            .map { (multipart: HttpBodyConvertible) -> Data in
                return multipart.buildHttpBodyPart(boundary: boundary)
            }
            .reduce(Data.init(), +)
            + boundaryEnding
    }
    
    func percentEncodedString() -> String {
        return params.map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            if let array = value as? [CustomStringConvertible] {
                return array.map { entry in
                    let escapedValue = "\(entry)"
                        .addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
                    return "\(key)[]=\(escapedValue)" }.joined(separator: "&"
                    )
            } else {
                let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
                return "\(escapedKey)=\(escapedValue)"
            }
        }
        .joined(separator: "&")
    }
}

// Thansks to https://stackoverflow.com/questions/26364914/http-request-in-swift-with-post-method
extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

extension NetworkingRequest: URLSessionTaskDelegate {
    
    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didSendBodyData bytesSent: Int64,
                           totalBytesSent: Int64,
                           totalBytesExpectedToSend: Int64) {
        let progress = Progress(totalUnitCount: totalBytesExpectedToSend)
        progress.completedUnitCount = totalBytesSent
        progressSubject.onNext(progress)
    }
    
}

public enum ParameterEncoding {
    case urlEncoded
    case json
}
