import Foundation

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