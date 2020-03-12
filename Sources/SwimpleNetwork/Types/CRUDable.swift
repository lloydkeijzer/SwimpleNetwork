//
//  File.swift
//  
//
//  Created by Lloyd Keijzer on 11/03/2020.
//

import Foundation
import Alamofire

public protocol CRUDable: Creatable, Requestable, Updatable, Removable {}

public extension CRUDable {
    
    var baseResourceUrl: String? {
        return Self.baseResourceUrl
    }
    
    var isAuthenticated: Bool {
        return Self.isAuthenticated
    }
    
    var resourceURL: URL? {
        guard let baseResourceUrl = baseResourceUrl, let id = id else { return nil }
        return URL(string: "\(baseResourceUrl)/\(id)")
    }
}
