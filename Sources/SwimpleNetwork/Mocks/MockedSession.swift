//
//  MockedSession.swift
//  
//
//  Created by Lloyd Keijzer on 11/03/2020.
//

import Foundation
import Alamofire

public struct Mocked {
    
    public static let AF: Session = {
        let configuration: URLSessionConfiguration = {
            let configuration = URLSessionConfiguration.default
            configuration.protocolClasses = [MockedURLProtocol.self]
            return configuration
        }()
        
        return Session(configuration: configuration)
    }()
    
    public static func response(withFailure error: Error) {
        MockedURLProtocol.responseType = MockedURLProtocol.ResponseType.error(error)
    }
    
    public static func response(withMockedData data: Data?, andStatusCode statusCode: Int) {
        MockedURLProtocol.responseType = MockedURLProtocol.ResponseType.success(
            response: HTTPURLResponse(
                url: URL(string: "http://any.com")!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!,
            data: data
        )
    }
    
    public static func response(withMockedJSONString jsonString: String, andStatusCode statusCode: Int) {
        response(withMockedData: jsonString.data(using: .utf8), andStatusCode: statusCode)
    }
    
    public static func response<T:Entity>(withMockedEntity entity: T, andStatusCode statusCode: Int) {
        response(withMockedData: try? JSONEncoder().encode(entity), andStatusCode: statusCode)
    }
    
    public static func response(withStatusCode statusCode: Int) {
        response(withMockedData: nil, andStatusCode: statusCode)
    }
}
