
import Foundation

public typealias DataProvider = (String) throws -> [String:Any]

public struct Endpoint {
    let path: String
    let provider: DataProvider
    
    public init(path: String, provider: @escaping DataProvider) {
        self.path = path
        self.provider = provider
    }
    
    public enum Error: Swift.Error {
        case requestedWrongPath(endpointPath: String, requestedPath: String)
        case noSchemaFoundOnDataProvider
        case noDataFoundOnDataProvider
        case unableToEncodeDataFromProvider
    }
    
    public func process(_ request: Request) throws(Error) -> Response {
        guard request.path == path else {
            throw Error.requestedWrongPath(endpointPath: path, requestedPath: request.path)
        }
        guard let data = try? provider(path) else {
            throw Error.noDataFoundOnDataProvider
        }
        guard let serialized = try? data.serialized() else {
            throw Error.unableToEncodeDataFromProvider
        }
        return Response(statusCode: 200, contentType: .applicationJSON, data: serialized)
    }
}

public struct Request  {
    public enum Method: String {
        case get
        case post
        case patch
        case put
        case delete
    }
    
    enum Error: Swift.Error {
        case noMethodFound
        case invalidMethod(String)
        case noPathFound
    }
    
    public let method: Method
    public let body: Data?
    public let path: String
    
    public init(method: Method, body: Data?, path: String) {
        self.method = method
        self.body = body
        self.path = path
    }
}

extension Request {
    public init(_ request: String) throws {
        let components = request.components(separatedBy: "\n\n")
        let headers = components.first?.components(separatedBy: "\n") ?? []
        let payload = components.count > 1 ? components[1].trimmingCharacters(in: .whitespacesAndNewlines) : nil
        
        
        method = try Self.method(headers)
        body = try Self.body(payload)
        path = try Self.path(headers)
    }
    
    init(_ buffer: Array<UInt8>) throws {
        try self.init(String(bytes: buffer, encoding: .utf8) ?? "")
    }
}

extension Request {
    static func method(_ headers: [String]) throws -> Method {
        let firstLine = headers.first?.components(separatedBy: " ")
        
        guard let stringMethod = firstLine?.first?.lowercased() else {
            throw Error.noMethodFound
        }
        
        guard let method = Method.init(rawValue: stringMethod) else {
            throw Error.invalidMethod(stringMethod)
        }
        
        return method        
    }
    
    public static func body(_ payload: String?) throws -> Data? {
        guard let payload, let data = payload.data(using: .utf8) else { return nil }
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        let normalizedData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
        
        return normalizedData
    }
    
    static func path(_ headers: [String]) throws -> String {
        let firstLine = headers.first?.components(separatedBy: " ")
        guard let path = firstLine?[idx: 1] else { throw Error.noPathFound }
        return path.first == "/" ? String(path.dropFirst()) : path
    }
}

fileprivate extension Array {
    subscript(idx idx: Int) -> Element? {
        indices.contains(idx) ? self[idx] : nil
    }
}

import Foundation

public struct Response {
    public let statusCode: Int
    public let contentType: ContentType
    public let data: Data?
    
    public init(statusCode: Int, contentType: ContentType, data: Data?) {
        self.statusCode = statusCode
        self.contentType = contentType
        self.data = data
    }
    
    // Sorting keys alphabetically is necessary so we can
    // have a deterministic rawValue. Otherwise, the json response would
    // have keys in a random order making the fails tests.
    // While I don't like this solution because we're implementing production code
    // for the sake of tests, I haven't think yet of a good solution
    public var json: String? {
        guard 
        let data,
        let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
        let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.sortedKeys]) else {
            return nil
        }
        return String(data: jsonData, encoding: .utf8)
    }
    
    var contentLength: Int {
        json?.utf8.count ?? 0
    }
    
    public enum ContentType {
        case applicationJSON
        case textHTML
        
        var value: String {
            switch self {
                case .applicationJSON: return "application/json"
                case .textHTML: return "text/html"
            }
        }
    }
    
    public var rawValue: String {
        headers + (json?.isNotEmpty == true ? "\n\n\(json!)" : "")
    }
    
    var headers: String {
        """
        HTTP/1.1 \(statusCode) OK
        Content-Type: \(contentType.value); charset=utf-8
        Content-Length: \(contentLength)
        """
    }
}


extension [String: Any] {
    public func serialized() throws -> Data {
        try JSONSerialization.data(withJSONObject: self)
    }
}


extension String {
    var isNotEmpty: Bool {!isEmpty}
}
