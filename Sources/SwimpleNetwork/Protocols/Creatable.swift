//
//  File.swift
//  
//
//  Created by Lloyd Keijzer on 11/03/2020.
//

import Foundation
import Alamofire

public protocol Creatable {
    associatedtype CreationResultCompletionHandler
    static var baseResourceUrl: String? { get }
    static var isAuthenticated: Bool { get }
    static func create(
        _ convertible: URLConvertible?,
        parameters: Parameters?,
        encoding: ParameterEncoding,
        headers: HTTPHeaders?,
        inteceptor: RequestInterceptor?,
        usingMockedSession isMockedSession: Bool,
        completion: CreationResultCompletionHandler
    )
    func create(
        _ convertible: URLConvertible?,
        encoder: ParameterEncoder,
        headers: HTTPHeaders?,
        inteceptor: RequestInterceptor?,
        usingMockedSession isMockedSession: Bool,
        completion: CreationResultCompletionHandler
    )
}

public extension Creatable where Self: Entity {
    
    static var baseResourceUrl: String? {
        return nil
    }
    
    static var isAuthenticated: Bool {
        return false
    }
    
    static func create(
        _ convertible: URLConvertible? = nil,
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
        } else if let baseResourceUrl = baseResourceUrl {
            requestUrl = baseResourceUrl
        } else {
            assertionFailure("Provide either a url convertible on creation or set the resource base url and resource id before creation")
            return
        }
        (isMockedSession ? Mocked.AF : AF).request(
            requestUrl,
            method: .post,
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
    
    func create(
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
        } else if let baseResourceUrl = Self.baseResourceUrl {
            requestUrl = baseResourceUrl
        } else {
            assertionFailure("Provide either a url convertible on creation or set the resource base url and resource id before creation")
            return
        }
        (isMockedSession ? Mocked.AF : AF).request(
            requestUrl,
            method: .post,
            parameters: self,
            encoder: encoder,
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
