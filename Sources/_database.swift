struct NoSchemaFound: Error {}
final class Database {
    nonisolated(unsafe) static let shared = Database()
    let storage = ["recipes": Database.recipes()]
    private init() {}
    
    func get(_ schema: String) throws -> [String: Any] {
        if let data = storage[schema] { return data }
        throw NoSchemaFound()
    }
    
    static func recipes() -> [String: Any] {
        ["recipes":[
            ["id": 1, "title": "Spaghetti Bolognese"],
            ["id": 2, "title": "Chicken Curry"],
            ["id": 3, "title": "Tacos"]]
        ]
    }
}

