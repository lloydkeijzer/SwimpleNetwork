//
//  File.swift
//  
//
//  Created by Lloyd Keijzer on 11/03/2020.
//

import Foundation

public typealias ResultCompletion<Value, ErrorType: Error> = ((Result<Value, ErrorType>) -> Void)
