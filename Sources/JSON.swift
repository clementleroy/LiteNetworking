import Foundation

/// The ParsingError codes generated by JSON.
enum ParsingError: Error {
    case notFound, failed
}

public enum JSON {
    case none

    case dictionary([String: Any])

    case array([[String: Any]])

    public var dictionary: [String: Any] {
        get {
            switch self {
            case .dictionary(let value):
                return value
            default:
                return [String: Any]()
            }
        }
    }

    public var array: [[String: Any]] {
        get {
            switch self {
            case .array(let value):
                return value
            default:
                return [[String: Any]]()
            }
        }
    }

    public init(_ dictionary: [String: Any]) {
        self = .dictionary(dictionary)
    }

    public init(_ array: [[String: Any]]) {
        self = .array(array)
    }

    public init() {
        self = .none
    }

    /// Returns a JSON object from a file.
    ///
    /// - Parameters:
    ///   - fileName: The name of the file, the expected extension is `.json`.
    ///   - bundle: The Bundle where the file is located, by default is the main bundle.
    /// - Returns: A JSON object, it can be either a Dictionary or an Array.
    /// - Throws: An error if it wasn't able to process the file.
    static func from(_ fileName: String, bundle: Bundle = Bundle.main) throws -> Any? {
        var json: Any?

        guard let url = URL(string: fileName), let filePath = bundle.path(forResource: url.deletingPathExtension().absoluteString, ofType: url.pathExtension) else { throw ParsingError.notFound }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else { throw ParsingError.failed }

        json = try data.toJSON()

        return json
    }
}

extension Data {

    /// Serializes Data into a JSON object.
    ///
    /// - Returns: A JSON object, it can be either a Dictionary or an Array.
    /// - Throws: An error if it couldn't serialize the data into json.
    func toJSON() throws -> Any? {
        var json: Any?
        do {
            json = try JSONSerialization.jsonObject(with: self, options: [])
        } catch {
            throw ParsingError.failed
        }

        return json
    }
}
