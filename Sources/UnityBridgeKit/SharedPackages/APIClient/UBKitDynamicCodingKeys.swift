//
//  UBKitDynamicCodingKeys.swift
//  UnityBridgeKit
//
//  Created by tom.pham on 21/8/24.
//

/// A custom `CodingKey` implementation used to dynamically create keys for encoding and decoding.
/// This is particularly useful when working with dictionaries where keys are not predefined at compile time.
struct UBKitDynamicCodingKeys: CodingKey {
    
    /// The string value of the coding key.
    var stringValue: String
    
    /// The integer value of the coding key.
    /// This implementation does not support integer keys, so it always returns `nil`.
    var intValue: Int? { return nil }
    
    /// Creates a new `UBKitDynamicCodingKeys` instance with the provided string value.
    ///
    /// - Parameter stringValue: The string value of the key.
    /// - Returns: A new instance of `UBKitDynamicCodingKeys`, or `nil` if the value cannot be represented as a key.
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    /// Creates a new `UBKitDynamicCodingKeys` instance with the provided integer value.
    ///
    /// - Parameter intValue: The integer value of the key.
    /// - Returns: Always returns `nil` since integer keys are not supported.
    init?(intValue: Int) {
        return nil
    }
}
