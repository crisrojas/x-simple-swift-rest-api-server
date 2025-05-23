import x_simple_swift_rest_api_server

struct NoSchemaFound: Error {}
final class Database {
    nonisolated(unsafe) static let shared = Database()
    let storage = ["recipes": Database.recipes()]
    private init() {}
    
    func get(_ schema: String) throws -> JSON {
        if let data = storage[schema] { return data }
        throw NoSchemaFound()
    }
    
    static func recipes() -> JSON {
        ["recipes":[
            ["id": 1, "title": "Spaghetti Bolognese"],
            ["id": 2, "title": "Chicken Curry"],
            ["id": 3, "title": "Tacos"]]
        ]
    }
}

