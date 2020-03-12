//
//  Product.swift
//  
//
//  Created by Lloyd Keijzer on 11/03/2020.
//

import Foundation
@testable import SwimpleNetwork

struct ProductEntity: Entity, CRUDable {
    static let baseResourceUrl: String? = "http://any.com/products"
    static let isAuthenticated: Bool = false
    
    let id: String?
    var uploadableImage: UploadableFile?
    var title: String?

    enum CodingKeys: String, CodingKey {
        case id
        case uploadableImage = "image"
        case title
    }
    
    init(id: String? = nil, image: String? = nil, title: String? = nil) {
        self.id = id
        if let filePath = image {
            self.uploadableImage = UploadableFile(
                fileName: CodingKeys.uploadableImage.stringValue,
                fileUrl: URL(fileURLWithPath: filePath)
            )
        } else {
            self.uploadableImage = nil
        }
        self.title = title
    }
}
