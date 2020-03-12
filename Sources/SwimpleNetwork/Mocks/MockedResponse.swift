//
//  MockedResponse.swift
//  
//
//  Created by Lloyd Keijzer on 11/03/2020.
//

import Foundation

enum MockedResponse {
    case getProduct
    case createProduct
    case updateProduct
    case uploadProductImage
    case wrappedProducts
    
    var jsonString: String {
        switch self {
        case .getProduct, .createProduct:
            return """
            {
                "id": "1",
                "image": "http://any.com",
                "title": "Product"
            }
            """
        case .updateProduct:
            return """
            {
                "id": "1",
                "image": "http://any.com",
                "title": "Updated Product"
            }
            """
        case .uploadProductImage:
            return """
            {
                "image": "http://any.com"
            }
            """
        case .wrappedProducts:
            return """
            {
                "products": [
                    {
                        "id": "1",
                        "image": "http://any.com",
                        "title": "Product 1"
                    },
                    {
                        "id": "2",
                        "image": "http://any.com",
                        "title": "Product 2"
                    },
                    {
                        "id": "3",
                        "image": "http://any.com",
                        "title": "Product 3"
                    }
                ]
            }
            """
        }
    }
    
    var data: Data {
        return jsonString.data(using: .utf8)!
    }
    
    var statusCode: Int {
        return 200
    }
}
