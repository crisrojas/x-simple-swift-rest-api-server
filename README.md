# Simple Swift REST-API Server

Exploration on how to build a lightweight dynamic minimal **REST API server** in Swift for learning purposes.

## Desired API

A simple but extensible API surface for declaring endpoints, inspired by declarative patterns.

```swift
let cd = CoreDataProvider()
let fs = FileSystemDataProvider()

let recipes = Endpoint(
	path: "recipes", 
	dataProvider: fs, 
	auth: .bearAuth
)

let todos = Endpoint(
	path: "todos", 
	dataProvider: cd
)

let users = Endpoint(path: "users", provider: fs)

Server(endpoits: [recipes, todos, users])
```
