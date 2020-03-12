//
//  File.swift
//  
//
//  Created by Lloyd Keijzer on 11/03/2020.
//

import Foundation
import Alamofire

public protocol Updatable {
    associatedtype UpdateResultCompletionHandler
    var baseResourceUrl: String? { get }
    var isAuthenticated: Bool { get }
    var id: String? { get }
    func update(
        _ convertible: URLConvertible?,
        encoder: ParameterEncoder,
        headers: HTTPHeaders?,
        inteceptor: RequestInterceptor?,
        usingMockedSession isMockedSession: Bool,
        completion: UpdateResultCompletionHandler
    )
}

public extension Updatable where Self: Entity {
    
    var baseResourceUrl: String? {
        return nil
    }
    
    var isAuthenticated: Bool {
        return false
    }
    
    func update(
        _ convertible: URLConvertible? = nil,
        encoder: ParameterEncoder = JSONParameterEncoder.default,
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
        } else {
            assertionFailure("Provide either a url convertible on updating or set the resource base url and resource id before updating")
            return
        }
        (isMockedSession ? Mocked.AF : AF).request(
            requestUrl,
            method: .put,
            parameters: self,
            encoder: encoder,
            headers: headers,
            interceptor: isAuthenticated
                ? inteceptor ?? URLRequestAuthenticator.shared
                : inteceptor
        )
            .validate(statusCode: 200..<300)
            .responseDecodable { (response) in
                completion(response.result)
            }
    }
}
