//
//  String+Extensions.swift
//  UnityBridgeKit
//
//  Created by Tuan Pham on 06/01/2024.
//

import Foundation

/// String extensions

public extension String {

    /// An "" string.
    static let empty = ""
}

public extension String {
    
    func toPointer() -> UnsafePointer<CChar>? {
        return NSString(string: self).utf8String
    }
}

public extension UnsafePointer where Pointee == CChar {
    
    func toString() -> String {
        return String(cString: self)
    }
}
