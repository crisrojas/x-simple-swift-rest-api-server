
import Foundation

final class EndpointTests: TestCase {
	
	@objc func test_endpoint_process_response() {
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
		
		do {
			let request = Request(method: .get, body: nil, path: "todos")
			let response = try endpoint.process(request)
			let expectedJSON = "{\"todos\":[{\"id\":1,\"isChecked\":false,\"title\":\"10 pushups\"},{\"id\":2,\"isChecked\":true,\"title\":\"Do laundry\"}]}"
			expect(response.json).toBe(.equalTo(expectedJSON))
		} catch {
			fail(error.localizedDescription)
		}
	}
}

final class RequestTests: TestCase {
	
	@objc func test_methods_decoding() {
		let get = "GET /api/v1/ / HTTP/1.1"
		let post = "POST /api/v1/ / HTTP/1.1"
		let put = "PUT /api/v1/ / HTTP/1.1"
		let patch = "PATCH /api/v1/ / HTTP/1.1"
		let delete = "DELETE /api/v1/ / HTTP/1.1"
		
		do {
			let getRequest = try Request(get)
			let postRequest = try Request(post)
			let putRequest = try Request(put)
			let patchRequest = try Request(patch)
			let deleteRequest = try Request(delete)
			
			expect(getRequest.method).toBe(.equalTo(.get), desc: "GET")
			expect(postRequest.method).toBe(.equalTo(.post), desc: "POST")
			expect(putRequest.method).toBe(.equalTo(.put), desc: "PUT")
			expect(patchRequest.method).toBe(.equalTo(.patch), desc: "PATCH")
			expect(deleteRequest.method).toBe(.equalTo(.delete), desc: "DELETE")
		} catch {
			fail(error.localizedDescription)
		}
	}
	
	@objc func test_path_decoding() {
		let request = "GET /api/v1/ / HTTP/1.1"
		
		do {
			let request = try Request(request)
			expect(request.path).toBe(.equalTo("api/v1/"))
		} catch {
			fail(error.localizedDescription)
		}
	}
	
	
	@objc func test_payload_normalization() {
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
		
		do {
			let request1 = try Request(string1)
			let request2 = try Request(string2)
			
			let expectedPayload = try Request.body("{\"key\":\"value\",\"anotherKey\":123}")
			expect(request2.body).toBe(.equalTo(expectedPayload), desc: "Request is normalized")
			expect(request1.body).toBe(.equalTo(request2.body), desc: "Request have same body even if different initial format")
		}
		catch {
			fail(error.localizedDescription)
		}
	}
}


final class ResponseTests: TestCase {
	
	@objc func test_response_creation_with_empty_data() {
		
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
		expect(response.rawValue).toBe(.equalTo(expectedValue))
	}
	
	@objc func test_response_creation_with_object() {
		
		do {
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
			
			expect(response.rawValue).toBe(.equalTo(expectedValue))
			
		} catch {
			fail(error.localizedDescription)
		}    
	}
}