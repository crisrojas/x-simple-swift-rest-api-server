// Created by Cristian Felipe Patiño Rojas on 7/5/25.

import XCTest
import x_simple_swift_rest_api_server


final class ResponseTests: XCTestCase {
    
    func test_response_creation_with_empty_data() {
        
        let expectedValue = """
        HTTP/1.1 200 OK
        Content-Type: application/json; charset=utf-8
        Content-Length: 0
        """
        
        let response = Response(
            statusCode: 200,
            contentType: .applicationJSON,
            data: Data()
        )
        XCTAssertEqual(response.rawValue, expectedValue)
    }
    
    func test_response_creation_with_object() throws {
        let object = try [
            "id": 1,
            "title": "Buy milk",
            "isChecked": false
        ].serialized()
        
        let expectedValue = """
            HTTP/1.1 200 OK
            Content-Type: application/json; charset=utf-8
            Content-Length: 45
            
            {"id":1,"isChecked":false,"title":"Buy milk"}
            """
        
        let response = Response(
            statusCode: 200,
            contentType: .applicationJSON,
            data: object
        )
        
        XCTAssertEqual(response.rawValue, expectedValue)
    }
}
