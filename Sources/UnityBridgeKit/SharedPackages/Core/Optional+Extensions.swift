//
//  Optional+Extensions.swift
//  UnityBridgeKit
//
//  Created by Tuan Pham on 06/01/2024.
//

import Foundation

public extension Optional {

    /// Returns the result of evaluating the given closure `f` if this `Optional` instance is `nil`, otherwise returns the wrapped value.
    /// 
    /// Use the nil-coalescing operator (`??`) to supply a default value in case the `Optional` instance is `nil`. You can use this
    /// operator with any type.
    /// 
    /// - Parameters:
    ///    - other: A value to use as a default. `other` is the default value when the value of this `Optional` instance is `nil`.
    ///
    /// - Returns: The result of evaluating `f` if this `Optional` instance is `nil`, otherwise the wrapped value.
    func or(_ other: Wrapped) -> Wrapped {
        return self ?? other
    }
}

public extension Optional where Wrapped == String {

    /// Returns the wrapped value if it is not `nil`, otherwise returns an empty string.
    var orEmpty: String {
        return or(.empty)
    }
}

public extension Optional where Wrapped: RangeReplaceableCollection {
    
    /// Returns the wrapped value if it is not `nil`, otherwise returns an empty collection.
    var orEmpty: Wrapped {
        return or(Wrapped())
    }
}
