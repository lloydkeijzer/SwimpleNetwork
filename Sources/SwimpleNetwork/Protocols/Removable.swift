//
//  File.swift
//  
//
//  Created by Lloyd Keijzer on 11/03/2020.
//

import Foundation
import Alamofire

public protocol Removable {
    associatedtype DeletionResultCompletionHandler
    var baseResourceUrl: String? { get }
    var isAuthenticated: Bool { get }
    var id: String? { get }
    func delete(
        _ convertible: URLConvertible?,
        parameters: Parameters?,
        encoding: ParameterEncoding,
        headers: HTTPHeaders?,
        inteceptor: RequestInterceptor?,
        usingMockedSession isMockedSession: Bool,
        completion: DeletionResultCompletionHandler
    )
}

public extension Removable where Self: Entity {
    
    var baseResourceUrl: String? {
        return nil
    }
    
    var isAuthenticated: Bool {
        return false
    }
    
    func delete(
        _ convertible: URLConvertible? = nil,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil,
        inteceptor: RequestInterceptor? = nil,
        usingMockedSession isMockedSession: Bool = false,
        completion: @escaping ResultCompletion<Data?, AFError>
    ) {
        var requestUrl: URLConvertible
        if let resourceUrl = convertible {
            requestUrl = resourceUrl
        } else if let baseResourceUrl = baseResourceUrl, let resourceId = id {
            requestUrl = "\(baseResourceUrl)/\(resourceId)"
        } else {
            assertionFailure("Provide either a url convertible on deletion or set the resource base url and resource id before deletion")
            return
        }
        (isMockedSession ? Mocked.AF : AF).request(
            requestUrl,
            method: .delete,
            parameters: parameters,
            encoding: encoding,
            headers: headers,
            interceptor: isAuthenticated
                ? inteceptor ?? URLRequestAuthenticator.shared
                : inteceptor
        )
            .validate(statusCode: 200..<300)
            .response { response in
                completion(response.result)
            }
    }
}
