// Created by Cristian Felipe Patiño Rojas on 7/5/25.

import XCTest
import x_simple_swift_rest_api_server

final class RequestTests: XCTestCase {
    
    func test_methods_decoding() throws {
        let get = "GET /api/v1/ / HTTP/1.1"
        let post = "POST /api/v1/ / HTTP/1.1"
        let put = "PUT /api/v1/ / HTTP/1.1"
        let patch = "PATCH /api/v1/ / HTTP/1.1"
        let delete = "DELETE /api/v1/ / HTTP/1.1"
        
        let getRequest = try Request(get)
        let postRequest = try Request(post)
        let putRequest = try Request(put)
        let patchRequest = try Request(patch)
        let deleteRequest = try Request(delete)
        
        XCTAssertEqual(getRequest.method, .get, "GET")
        XCTAssertEqual(postRequest.method, .post, "POST")
        XCTAssertEqual(putRequest.method, .put, "PUT")
        XCTAssertEqual(patchRequest.method, .patch, "PATCH")
        XCTAssertEqual(deleteRequest.method, .delete, "DELETE")
    }
    
    func test_path_decoding() throws {
        try XCTExpectFailure("Investigate if this was really the desired behaviour") {
            let path = "GET /api/v1/ / HTTP/1.1"
            let request = try Request(path)
            XCTAssertEqual(request.path, "/api/v1/")
        }
    }
    
    func test_payload_normalization() throws {
        let string1 = """
        POST / HTTP/1.1
        
        {"key":"value","anotherKey":123}
        """
        
        let string2 = """
        POST / HTTP/1.1
        
        {
            "key":"value",
            "anotherKey":123
        }
        """
        
        let request1 = try Request(string1)
        let request2 = try Request(string2)
        
        let expectedPayload = try Request.body("{\"key\":\"value\",\"anotherKey\":123}")
        
        XCTAssertEqual(request2.body, expectedPayload, "Request is normalized")
        XCTAssertEqual(request1.body, request2.body, "Request have same body even if different initial format")
    }
}
