//
//  Requestable.swift
//
//
//  Created by Lloyd Keijzer on 11/03/2020.
//

import Foundation
import Alamofire

public protocol Requestable {
    associatedtype RequestResultCompletionHandler
    static var baseResourceUrl: String? { get }
    static var isAuthenticated: Bool { get }
    static func get(
        _ convertible: URLConvertible?,
        id: String?,
        parameters: Parameters?,
        encoding: ParameterEncoding,
        headers: HTTPHeaders?,
        inteceptor: RequestInterceptor?,
        usingMockedSession isMockedSession: Bool,
        completion: RequestResultCompletionHandler
    )
}

public extension Requestable where Self: Entity {
    
    static var baseResourceUrl: String? {
        return nil
    }
    
    static var isAuthenticated: Bool {
        return false
    }
    
    static func get(
        _ convertible: URLConvertible? = nil,
        id: String? = nil,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil,
        inteceptor: RequestInterceptor? = nil,
        usingMockedSession isMockedSession: Bool = false,
        completion: @escaping ResultCompletion<Self, AFError>
    ) {
        var requestUrl: URLConvertible
        if let resourceUrl = convertible {
            requestUrl = resourceUrl
        } else if let baseResourceUrl = baseResourceUrl, let resourceId = id {
            requestUrl = "\(baseResourceUrl)/\(resourceId)"
        } else if let baseResourceUrl = baseResourceUrl {
            requestUrl = baseResourceUrl
        } else {
            assertionFailure("Provide either a url convertible on read or set the resource base url and resource id before read")
            return
        }
        (isMockedSession ? Mocked.AF : AF).request(
            requestUrl,
            method: .get,
            parameters: parameters,
            encoding: encoding,
            headers: headers,
            interceptor: Self.isAuthenticated
                ? inteceptor ?? URLRequestAuthenticator.shared
                : inteceptor
        )
            .validate(statusCode: 200..<300)
            .responseDecodable { (response: DataResponse<Self, AFError>) in
                completion(response.result)
            }
    }
}
