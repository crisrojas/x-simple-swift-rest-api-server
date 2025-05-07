// Created by Cristian Felipe Patiño Rojas on 7/5/25.


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
