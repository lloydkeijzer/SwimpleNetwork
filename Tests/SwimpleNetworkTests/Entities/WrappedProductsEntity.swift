//
//  WrappedProducts.swift
//  
//
//  Created by Lloyd Keijzer on 12/03/2020.
//

import Foundation
@testable import SwimpleNetwork

struct WrappedProductsEntity: Entity, Requestable {
    // Requestable
    static let baseResourceUrl: String? = "http://any.com/products"
    static let isAuthenticated: Bool = true
    
    // Entity
    let products: [ProductEntity]
}
