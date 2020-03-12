//
//  Uploadable.swift
//  
//
//  Created by Lloyd Keijzer on 11/03/2020.
//

import Foundation
import Alamofire

public struct UploadableFile: Codable {
    
    public var fileName: String?
    public var fileURL: URL
    public var uploadURL: URLConvertible?
    
    public init(fileName: String? = nil, fileUrl: URL, to convertible: URLConvertible? = nil) {
        self.fileName = fileName
        self.fileURL = fileUrl
        self.uploadURL = convertible
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.fileName = container.codingPath.last?.stringValue
        self.fileURL = try container.decode(URL.self)
        self.uploadURL = nil
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(fileURL)
    }
    
    public func upload(
        to convertible: URLConvertible? = nil,
        inteceptor: RequestInterceptor? = nil,
        isAuthenticated: Bool = false,
        usingMockedSession isMockedSession: Bool = false
    ) -> UploadRequest {
        guard let uploadURL = convertible ?? uploadURL else {
            fatalError("Upload failed: Upload url isn't set yet")
        }
        var uploadRequest: UploadRequest
        
        if let fileName = fileName {
            uploadRequest = (isMockedSession ? Mocked.AF : AF).upload(multipartFormData: { multipartFormData in
                multipartFormData.append(self.fileURL, withName: fileName)
            }, to: uploadURL, interceptor: isAuthenticated
                ? inteceptor ?? URLRequestAuthenticator.shared
                : inteceptor
            )
        } else {
            uploadRequest = (isMockedSession ? Mocked.AF : AF).upload(fileURL, to: uploadURL, interceptor: isAuthenticated
                ? inteceptor ?? URLRequestAuthenticator.shared
                : inteceptor
            )
        }
        
        return uploadRequest.validate(statusCode: 200..<300)
    }
}
