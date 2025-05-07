// Created by Cristian Felipe Patiño Rojas on 7/5/25.

import XCTest
import x_simple_swift_rest_api_server

final class EndpointTests: XCTestCase {
    
    func test_endpoint_process_response() throws {
        let endpoint = Endpoint(path: "todos") { path in
            if path == "todos" {
                return [
                    "todos": [
                        ["id": 1, "title": "10 pushups", "isChecked": false],
                        ["id": 2, "title": "Do laundry", "isChecked": true ]
                    ]
                ]
            } else {
                throw Endpoint.Error.noSchemaFoundOnDataProvider
            }
        }
        
        let request = Request(method: .get, body: nil, path: "todos")
        let response = try endpoint.process(request)
        let expectedJSON = "{\"todos\":[{\"id\":1,\"isChecked\":false,\"title\":\"10 pushups\"},{\"id\":2,\"isChecked\":true,\"title\":\"Do laundry\"}]}"
        
        XCTAssertEqual(response.json, expectedJSON)
    }
}
