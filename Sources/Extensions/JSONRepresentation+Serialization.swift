// Created by Cristian Felipe Patiño Rojas on 7/5/25.

import Foundation

public typealias JSON = [String: Any]
extension JSON {
    public func serialized() throws -> Data {
        try JSONSerialization.data(withJSONObject: self)
    }
}

