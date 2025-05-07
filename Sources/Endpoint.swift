
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

extension [String: Any] {
    public func serialized() throws -> Data {
        try JSONSerialization.data(withJSONObject: self)
    }
}


extension String {
    var isNotEmpty: Bool {!isEmpty}
}
