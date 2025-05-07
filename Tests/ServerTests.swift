
import XCTest
import x_simple_swift_rest_api_server

final class ServerTests: XCTestCase {
    
    func test_server_process_response() throws {
        
        let todos: JSON =  [
            "todos": [
                ["id": 1, "title": "10 pushups", "isChecked": false],
                ["id": 2, "title": "Do laundry", "isChecked": true ]
            ]
        ]
        
        let endpoint = Endpoint(path: "todos") { path in
            if path == "todos" {
                return todos
            } else {
                throw Endpoint.Error.noSchemaFoundOnDataProvider
            }
        }
        
        let server = Server(endpoints: [endpoint])
        let request = Request(method: .get, body: nil, path: "todos")
        let response = try server.response(for: request)
        
        let expectedResponse = Response(
            statusCode: 200,
            contentType: .applicationJSON,
            data: try todos.serialized()
        )
        
        XCTAssertEqual(response, expectedResponse)
    }
}


extension Response: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.statusCode == rhs.statusCode &&
        lhs.contentType == rhs.contentType &&
        lhs.data == rhs.data
    }
}
