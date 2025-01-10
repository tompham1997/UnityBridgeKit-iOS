//
//  UBKitAnyCodableTests.swift
//  UnityBridgeKit
//
//  Created by Tuan on 11/1/25.
//

import Foundation
import Testing
@testable import UnityBridgeKit

struct UBKitAnyCodableTests {
    
    @Test("Test encoding and decoding of primitive types")
    func testPrimitiveTypes() {
        // Test cases for primitive types
        let testValues: [Any] = [123, 123.45, "test", true]
        
        for value in testValues {
            // Given
            let anyCodable = UBKitAnyCodable(value)
            
            // When
            let encodedData = try! JSONEncoder().encode(anyCodable)
            let decodedValue = try! JSONDecoder().decode(UBKitAnyCodable.self, from: encodedData).value
            
            // Then
            #expect(String(describing: decodedValue) == String(describing: value),
                    "Decoded value \(decodedValue) should match the original value \(value)")
        }
    }
    
    @Test("Test encoding and decoding of arrays")
    func testArrays() {
        // Given
        let arrayValue: [Any] = [123, 123.45, "test", true]
        let anyCodable = UBKitAnyCodable(arrayValue)
        
        // When
        let encodedData = try! JSONEncoder().encode(anyCodable)
        let decodedValue = try! JSONDecoder().decode(UBKitAnyCodable.self, from: encodedData).value as! [Any]
        
        // Then
        #expect(decodedValue.count == arrayValue.count, "Array count should match")
        for (index, element) in decodedValue.enumerated() {
            #expect(String(describing: element) == String(describing: arrayValue[index]),
                    "Decoded array element should match original")
        }
    }
    
    @Test("Test encoding and decoding of dictionaries")
    func testDictionaries() {
        // Given
        let dictionaryValue: [String: Any] = [
            "intKey": 123,
            "doubleKey": 123.45,
            "stringKey": "test",
            "boolKey": true,
            "arrayKey": [1, 2, 3]
        ]
        let anyCodable = UBKitAnyCodable(dictionaryValue)
        
        // When
        let encodedData = try! JSONEncoder().encode(anyCodable)
        let decodedValue = try! JSONDecoder().decode(UBKitAnyCodable.self, from: encodedData).value as! [String: Any]
        
        // Then
        #expect(decodedValue.count == dictionaryValue.count, "Dictionary count should match")
        for key in dictionaryValue.keys {
            #expect(String(describing: decodedValue[key]) == String(describing: dictionaryValue[key]),
                    "Decoded dictionary value for key \(key) should match original")
        }
    }
    
    @Test("Test unsupported type handling")
    func testUnsupportedType() {
        // Given
        let unsupportedValue = NSObject()
        let anyCodable = UBKitAnyCodable(unsupportedValue)
        
        // When
        #expect(throws: (any Error).self) {
            try JSONEncoder().encode(anyCodable)
        }
    }
}
