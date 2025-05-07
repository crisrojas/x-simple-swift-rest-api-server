// Created by Cristian Felipe Patiño Rojas on 7/5/25.
import Foundation

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

// MARK: - Parsing helpers
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
