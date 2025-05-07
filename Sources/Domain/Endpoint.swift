
import Foundation

public typealias DataProvider = (String) throws -> JSON

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
