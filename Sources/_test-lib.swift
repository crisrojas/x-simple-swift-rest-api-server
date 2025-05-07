
import Foundation


// expect().toBe()

struct Expectation<T: Equatable> {
	let value: T
	
	enum ToBe {
		case equalTo(T)
	}
	
	func toBe(_ toBeCase: ToBe, line: UInt = #line, functionName: String = #function, desc: String = "") {
		switch toBeCase {
			case .equalTo(let item): toBe(item, line: line, functionName: functionName, desc: desc)
		}
	}
	
	private func toBe(_ expectedValue: T, line: UInt = #line, functionName: String = #function, desc: String) {
		assertEqual(value, expectedValue, line: line, functionName: functionName, desc)
	}
	
	func notToBe(_ expectedValue: T?, line: UInt = #line, functionName: String = #function) {
		assert(value != expectedValue, line: line, functionName: functionName)
	}
}

@discardableResult
func expect<T>(_ object: T) -> Expectation<T> {
	.init(value: object)
}


struct assert {
	@discardableResult
	init(_ condition: Bool, line: UInt = #line, functionName: String = #function, _ description: String = "") {
		let emoji = condition ? "✅" : "❌"
		//let description = condition ? "" : description
		let description = description.isEmpty ? "" : "— \(description)"
		print(line.description + " " + emoji + " " + functionName + " " + description)
	}
}

struct assertEqual {
	@discardableResult
	init<T: Equatable>(_ lhs: T, _ rhs: T, line: UInt = #line, functionName: String = #function, _ description: String = "") {
		let description = lhs != rhs ? "\(lhs) != \(rhs)" : description
		assert(lhs == rhs, line: line, functionName: functionName, description)
	}
}

struct assertNotNil {
	@discardableResult
	init<T>(_ object: T?, line: UInt = #line, functionName: String = #function, _ description: String = "") {
		assert(object != nil, line: line, functionName: functionName, description)
	}
}

struct fail {
	@discardableResult
	init(_ message: String = "", line: UInt = #line, functionName: String = #function, _ description: String = "") {
		print(line.description + " " + "❌" + " " + message)
	}
}

protocol TestCase: AnyObject {}
extension TestCase {
	func run() {callAllVoidMethods(from: self)}
}

func callAllVoidMethods(from object: AnyObject) {
	var count: UInt32 = 0
	let methods = class_copyMethodList(type(of: object), &count)
	
	for i in 0..<Int(count) {
		let method = methods![i]
		let selector = method_getName(method)
		if method_getNumberOfArguments(method) == 2 {
			let implementation = method_getImplementation(method)
			typealias Function = @convention(c) (AnyObject, Selector) -> Void
			let function = unsafeBitCast(implementation, to: Function.self)
			function(object, selector)
		}
	}
	
	free(methods)
}
