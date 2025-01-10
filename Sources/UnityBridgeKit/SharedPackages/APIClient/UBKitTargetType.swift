//
//  UBKitTargetType.swift
//  UnityBridgeKit
//
//  Created by Tuan on 10/1/25.
//

import Foundation

/// A protocol that represents the structure and behavior of a Unity Bridge target type.
/// Conforming types must be encodable and provide the following properties and methods.
///
/// ## Example Usage:
///
/// ```swift
/// struct UserProfileRequest: UBKitTargetType {
///     var id: UUID = UUID()
///     var path: String = "user/profile"
///     var parameters: [String: Any]? = ["userId": 12345]
///     var method: UBKitRequestMethod = .get
/// }
///
/// let request = UserProfileRequest()
/// print(request.encodedToJSONString())  // Encodes the request to a JSON string.
/// ```
///
/// This protocol can be used to define API-like target types for Unity Bridge operations.
public protocol UBKitTargetType: Encodable {
    
    /// A unique identifier for the target type instance.
    var id: UUID { get }
    
    /// The path associated with the target type, often representing an endpoint or resource.
    var path: String { get }
    
    /// Optional parameters that may be sent with the target type.
    var parameters: [String: Any]? { get }
    
    /// The request method to be used (e.g., GET, POST, etc.).
    var method: UBKitRequestMethod { get }
}

fileprivate extension UBKitTargetType {
    
    /// Generates a unique notification name using the path, id, and method of the target type.
    var notificationName: Notification.Name {
        let rawValue = "\(path)_\(id)_\(method.rawValue)"
        return .init(rawValue: rawValue)
    }
}

/// Enum for defining coding keys used when encoding instances of `UBKitTargetType`.
///
/// Example of how to parse JSON into a type conforming to `UBKitTargetType`.
///
/// Suppose we have the following JSON structure:
/// ```json
/// {
///   "id": "a5b90e40-f9e1-4d1b-8bdf-c2b3e29b5c25",
///   "path": "user/profile",
///   "parameters": {
///     "userId": 12345,
///     "isAdmin": true
///   }
/// }
/// ```
///
/// Here's how you can parse it:
///
/// ```swift
/// struct UserProfileRequest: UBKitTargetType {
///     var id: UUID
///     var path: String
///     var parameters: [String: Any]?
///     var method: UBKitRequestMethod = .get
///
///     init(from decoder: Decoder) throws {
///         let container = try decoder.container(keyedBy: UBKitTargetTypeCodingKeys.self)
///         id = try container.decode(UUID.self, forKey: .id)
///         path = try container.decode(String.self, forKey: .path)
///
///         // Decode parameters as [String: Any]
///         if let parametersData = try? container.decodeIfPresent([String: Any].self, forKey: .parameters) {
///             parameters = parametersData
///         } else {
///             parameters = nil
///         }
///     }
/// }
///
/// // Example Usage
/// let json = """
/// {
///   "id": "a5b90e40-f9e1-4d1b-8bdf-c2b3e29b5c25",
///   "path": "user/profile",
///   "parameters": {
///     "userId": 12345,
///     "isAdmin": true
///   }
/// }
/// """
///
/// if let jsonData = json.data(using: .utf8) {
///     do {
///         let decoder = JSONDecoder()
///         let request = try decoder.decode(UserProfileRequest.self, from: jsonData)
///         print(request)
///     } catch {
///         print("Failed to decode JSON: \(error)")
///     }
/// }
/// ``` 
fileprivate enum UBKitTargetTypeCodingKeys: String, CodingKey {
    case path
    case id
    case parameters
}

public extension UBKitTargetType {
    
    /// Encodes the target type into a JSON string.
    /// - Returns: A JSON string representation of the target type, or an empty string if encoding fails.
    func encodedToJSONString() -> String {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self)
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            print(error)
            return ""
        }
    }
    
    /// Custom encoding logic for the target type.
    /// Handles complex encoding of `parameters` with support for various data types.
    func encode(to encoder: any Encoder) throws {
        // Define a container for the main keys.
        var container = encoder.container(keyedBy: UBKitTargetTypeCodingKeys.self)
        
        // Encode the basic properties.
        try container.encode(path, forKey: .path)
        try container.encode(id, forKey: .id)
        
        // Encode the `parameters` dictionary, if it exists.
        if let parameters {
            for (_, _) in parameters {
                // Create a nested container for the parameters.
                var parametersContainer = container.nestedContainer(keyedBy: UBKitDynamicCodingKeys.self, forKey: .parameters)
                
                for (key, value) in parameters {
                    // Convert dictionary keys to dynamic coding keys.
                    let dynamicKey = UBKitDynamicCodingKeys(stringValue: key)!
                    
                    // Encode values based on their type.
                    switch value {
                    case let v as String:
                        try parametersContainer.encode(v, forKey: dynamicKey)
                        
                    case let v as Int:
                        try parametersContainer.encode(v, forKey: dynamicKey)
                        
                    case let v as Double:
                        try parametersContainer.encode(v, forKey: dynamicKey)
                        
                    case let v as Bool:
                        try parametersContainer.encode(v, forKey: dynamicKey)
                        
                    case let v as [String: Any]:
                        // Handle nested dictionaries.
                        let nestedData = try JSONSerialization.data(withJSONObject: v, options: [])
                        let nestedObject = try JSONDecoder().decode([String: UBKitAnyCodable].self, from: nestedData)
                        try parametersContainer.encode(nestedObject, forKey: dynamicKey)
                        
                    case let v as [Any]:
                        // Handle arrays of values.
                        let nestedData = try JSONSerialization.data(withJSONObject: v, options: [])
                        let nestedArray = try JSONDecoder().decode([UBKitAnyCodable].self, from: nestedData)
                        try parametersContainer.encode(nestedArray, forKey: dynamicKey)
                        
                    case let v as Encodable:
                        // Handle generic encodable values.
                        try parametersContainer.encode(v, forKey: dynamicKey)
                        
                    default:
                        // Throw an error for unsupported types.
                        throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: container.codingPath, debugDescription: "Unsupported type"))
                    }
                }
            }
        }
    }
}
