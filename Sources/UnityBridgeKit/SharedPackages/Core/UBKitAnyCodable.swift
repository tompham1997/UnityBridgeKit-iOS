//
//  UBKitAnyCodable.swift
//  UnityBridgeKit
//
//  Created by tom.pham on 21/8/24.
//

import Foundation

/// A generic wrapper for encoding and decoding values of any type.
/// This struct enables handling of heterogeneous data (e.g., mixed arrays or dictionaries)
/// that conforms to the `Codable` protocol.
public struct UBKitAnyCodable: Codable {
    
    /// The value being wrapped, which can be of any type.
    public var value: Any
    
    /// Initializes a new instance of `UBKitAnyCodable` with the given value.
    ///
    /// - Parameter value: The value to be wrapped, of any type.
    public init(_ value: Any) {
        self.value = value
    }
    
    /// Decodes an `UBKitAnyCodable` instance from a decoder.
    /// Attempts to decode the value as a known type (e.g., `Int`, `Double`, `String`, etc.),
    /// and falls back to arrays or dictionaries of nested `UBKitAnyCodable` objects if needed.
    ///
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: A `DecodingError` if the type cannot be decoded.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        // Attempt to decode as common types
        if let intValue = try? container.decode(Int.self) {
            self.value = intValue
            return
        }
        
        if let doubleValue = try? container.decode(Double.self) {
            self.value = doubleValue
            return
        }
        
        if let stringValue = try? container.decode(String.self) {
            self.value = stringValue
            return
        }
        
        if let boolValue = try? container.decode(Bool.self) {
            self.value = boolValue
            return
        }
        
        // Attempt to decode as an array of `UBKitAnyCodable`
        if let nestedArray = try? container.decode([UBKitAnyCodable].self) {
            self.value = nestedArray.map { $0.value }
            return
        }
        
        // Attempt to decode as a dictionary with `String` keys and `UBKitAnyCodable` values
        if let nestedDictionary = try? container.decode([String: UBKitAnyCodable].self) {
            self.value = nestedDictionary.mapValues { $0.value }
            return
        }
        
        // If decoding fails, throw an error
        throw DecodingError.typeMismatch(UBKitAnyCodable.self, DecodingError.Context(
            codingPath: decoder.codingPath,
            debugDescription: "Unsupported type"
        ))
    }
    
    /// Encodes the wrapped value into an encoder.
    /// Attempts to encode the value as a known type (e.g., `Int`, `Double`, `String`, etc.),
    /// or as nested arrays or dictionaries of `UBKitAnyCodable` objects.
    ///
    /// - Parameter encoder: The encoder to write data to.
    /// - Throws: An `EncodingError` if the type cannot be encoded.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let intValue as Int:
            try container.encode(intValue)
            
        case let doubleValue as Double:
            try container.encode(doubleValue)
            
        case let stringValue as String:
            try container.encode(stringValue)
            
        case let boolValue as Bool:
            try container.encode(boolValue)
            
        case let arrayValue as [Any]:
            // Encode each element in the array as `UBKitAnyCodable`
            let nestedArray = arrayValue.map { UBKitAnyCodable($0) }
            try container.encode(nestedArray)
            
        case let dictionaryValue as [String: Any]:
            // Encode each value in the dictionary as `UBKitAnyCodable`
            let nestedDictionary = dictionaryValue.mapValues { UBKitAnyCodable($0) }
            try container.encode(nestedDictionary)
            
        default:
            // If the type is unsupported, throw an error
            throw EncodingError.invalidValue(value, EncodingError.Context(
                codingPath: encoder.codingPath,
                debugDescription: "Unsupported type"
            ))
        }
    }
}
