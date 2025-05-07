import Foundation

public final class Server {
    
    let port: UInt16
    var endpoints: [Endpoint]
    
    public init(port: UInt16 = 8080, endpoints: [Endpoint] = []) {
        self.port = port
        self.endpoints = endpoints
    }
    
    func run() {
        
        let _socket = socket(AF_INET, SOCK_STREAM, 0)
        guard _socket >= 0 else {
            fatalError("Unable to create socket")
        }
        
        var value: Int32 = 1
        setsockopt(_socket, SOL_SOCKET, SO_REUSEADDR, &value, socklen_t(MemoryLayout<Int32>.size))
        
        var serverAddress = sockaddr_in()
        serverAddress.sin_family = sa_family_t(AF_INET)
        serverAddress.sin_port = in_port_t(port).bigEndian
        serverAddress.sin_addr = in_addr(s_addr: INADDR_ANY)
        
        let bindResult = withUnsafePointer(to: &serverAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                bind(_socket, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }
        guard bindResult >= 0 else {
            fatalError("Error al enlazar el socket. Intenta con otro puerto")
        }
        
        guard listen(_socket, 10) >= 0 else {
            fatalError("Error al escuchar en el socket.")
        }
        
        print("Servidor escuchando en el puerto \(port)...")
        
        while true {
            var clientAddress = sockaddr_in()
            var clientAddressLength = socklen_t(MemoryLayout<sockaddr_in>.size)
            let clientSocket = withUnsafeMutablePointer(to: &clientAddress) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    accept(_socket, $0, &clientAddressLength)
                }
            }
            
            guard clientSocket >= 0 else {
                print("Error al aceptar la conexión.")
                continue
            }
            
            var buffer = [UInt8](repeating: 0, count: 1024)
            let bytesRead = read(clientSocket, &buffer, 1024)
            
            guard bytesRead > 0 else {
                print("No se leyeron datos.")
                close(clientSocket)
                continue
            }
            
            do {
                
                let request = try Request(buffer)
                let response = try response(for: request)
                _ = response.rawValue.withCString { body in
                    write(clientSocket, body, strlen(body))
                }
                
                close(clientSocket)
                
            } catch let error as CustomError {
                _ = Response(
                    statusCode: 500,
                    contentType: .applicationJSON,
                    data: try! error.encoded()
                ).rawValue.withCString { body in
                    write(clientSocket, body, strlen(body))
                }
                
                close(clientSocket)
            } catch let error as ServerError {
                _ = Response(
                    statusCode: 500,
                    contentType: .applicationJSON,
                    data: try! CustomError(code: 500, description: error.message).encoded()
                ).rawValue.withCString { body in
                    write(clientSocket, body, strlen(body))
                }
                
                close(clientSocket)
                
            } catch {
                print("@todo")
            }
        }
    }
    
    
    enum ServerError: Error {
        case noEndpointFound(String)
        
        var message: String {
            switch self {
            case .noEndpointFound(let path): return "No endpoint found for \(path)"
            }
        }
    }
    
    // Encodable custom error
    // to send to the client
    struct CustomError: Error, Encodable {
        let code: Int
        let description: String
    }
    
    public func response(for request: Request) throws -> Response {
        guard let endpoint = endpoints.first(where:{ $0.path == request.path }) else {
            throw ServerError.noEndpointFound(request.path)
        }
        return try endpoint.process(request)
    }
}
