//
//  URLRequestAuthenticator.swift
//  
//
//  Created by Lloyd Keijzer on 12/03/2020.
//

import Foundation
import Alamofire

public final class URLRequestAuthenticator: RequestInterceptor {

    public static let shared = URLRequestAuthenticator()
    
    /// Store the access token preferable in a Keychain wrapper
    public var accessToken: String
    public var isBearer: Bool
    
    public var refreshTokenDataRequest: DataRequest?
    
    private init() {
        accessToken = ""
        isBearer = true
    }
    
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest

        /// Set the Authorization header value using the access token.
        urlRequest.setValue(isBearer
            ? "Bearer " + accessToken
            : accessToken,
        forHTTPHeaderField: "Authorization")

        completion(.success(urlRequest))
    }
    
    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            /// The request did not fail due to a 401 Unauthorized response.
            /// Return the original error and don't retry the request.
            return completion(.doNotRetryWithError(error))
        }
        
        refreshToken { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let accessToken):
                self.accessToken = accessToken
                // Used for unit testing
                Mocked.response(
                    withMockedData: MockedResponse.wrappedProducts.data,
                    andStatusCode: MockedResponse.wrappedProducts.statusCode
                )
                completion(.retry)
            case .failure(let error):
                completion(.doNotRetryWithError(error))
            }
        }
    }
    
    public func refreshToken(
        completion: @escaping ResultCompletion<String, AFError>
    ) {
        guard let dataRequest = refreshTokenDataRequest else {
            completion(.failure(.explicitlyCancelled))
            return
        }
        // Used for unit testing
        Mocked.response(
            withMockedJSONString: "newaccesstoken",
            andStatusCode: 200
        )
        dataRequest.responseString { response in
            completion(response.result)
        }
    }
}
