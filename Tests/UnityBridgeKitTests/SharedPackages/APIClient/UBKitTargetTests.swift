//
//  UBKitTargetTests.swift
//  UnityBridgeKit
//
//  Created by Tuan on 10/1/25.
//

import Foundation
import Testing
@testable import UnityBridgeKit

struct UBKitTargetTypeTests {
    
    @Test("Test JSON encoding with valid parameters")
    func testEncodedToJSONString() {
        // Given
        let target = MockTarget(
            id: UUID(uuidString: "353CDD82-69D5-49B4-9927-CDDFECF51FCE")!,
            path: "/test/path",
            parameters: ["key": "value"],
            method: .get
        )
        
        // When
        let jsonString = target.encodedToJSONString()
        print("Generated JSON String: \(jsonString)") // Debugging output
        
        // Then
        #expect(!jsonString.isEmpty, "JSON string should not be empty")
        #expect(jsonString.contains("\"key\":\"value\""), "JSON string should contain parameters")
    }

    @Test("Test notification name generation")
    func testNotificationNameGeneration() {
        // Given
        let target = MockTarget(
            id: UUID(uuidString: "353CDD82-69D5-49B4-9927-CDDFECF51FCE")!,
            path: "/test/path",
            parameters: nil,
            method: .post
        )
        
        // When
        let notificationName = "\(target.path)_\(target.id)_\(target.method.rawValue)"
        
        // Then
        #expect(notificationName == "/test/path_353CDD82-69D5-49B4-9927-CDDFECF51FCE_1",
                "Notification name should match the expected format")
    }

    @Test("Test JSON encoding with various parameter types")
    func testEncodingWithVariousParameters() {
        // Given
        let parameters: [String: Any] = [
            "stringKey": "stringValue",
            "intKey": 123,
            "doubleKey": 123.45,
            "boolKey": true,
            "arrayKey": [1, 2, 3],
            "dictionaryKey": ["nestedKey": "nestedValue"]
        ]
        let target = MockTarget(
            id: UUID(uuidString: "353CDD82-69D5-49B4-9927-CDDFECF51FCE")!,
            path: "/test/parameters",
            parameters: parameters,
            method: .post
        )
        
        // When
        let jsonString = target.encodedToJSONString()
        
        // Then
        #expect(jsonString.contains("\"stringKey\":\"stringValue\""), "Should encode string parameter")
        #expect(jsonString.contains("\"intKey\":123"), "Should encode int parameter")
        #expect(jsonString.contains("\"doubleKey\":123.45"), "Should encode double parameter")
        #expect(jsonString.contains("\"boolKey\":true"), "Should encode bool parameter")
        #expect(jsonString.contains("\"arrayKey\":[1,2,3]"), "Should encode array parameter")
        #expect(jsonString.contains("\"dictionaryKey\":{\"nestedKey\":\"nestedValue\"}"),
                "Should encode nested dictionary parameter")
    }

    @Test("Test encoding fails for unsupported parameter type")
    func testEncodingFailsForUnsupportedType() {
        // Given
        let unsupportedParameter: [String: Any] = [
            "unsupportedKey": NSObject() // NSObject is not Encodable
        ]
        let target = MockTarget(
            id: UUID(),
            path: "/unsupported",
            parameters: unsupportedParameter,
            method: .get
        )
        
        // When
        let jsonString = target.encodedToJSONString()
        
        // Then
        #expect(jsonString.isEmpty, "Encoding should fail for unsupported parameter types and return an empty string")
    }
}
