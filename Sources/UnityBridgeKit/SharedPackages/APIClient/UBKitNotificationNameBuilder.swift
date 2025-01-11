//
//  UBKitNotificationNameBuilder.swift
//  UnityBridgeKit
//
//  Created by Tuan on 11/1/25.
//

import Foundation

/// A utility class to build unique `Notification.Name` instances
/// by combining path, id, and method into a single string.
final class UBKitNotificationNameBuilder {
    
    // MARK: - Private Properties
    
    /// Stores the path component for the notification name.
    private var path: String?
    
    /// Stores the id component for the notification name.
    private var id: String?
    
    /// Stores the method component for the notification name.
    private var method: String?
    
    // MARK: - Initialization
    
    /// Default initializer.
    init() {}
    
    // MARK: - Builder Methods
    
    /// Sets the path component for the notification name.
    /// - Parameter path: The path string to include.
    /// - Returns: The current instance of `UBKitNotificationNameBuilder` for chaining.
    @discardableResult func setPath(_ path: String) -> UBKitNotificationNameBuilder {
        self.path = path
        return self
    }
    
    /// Sets the id component for the notification name.
    /// - Parameter id: The id string to include.
    /// - Returns: The current instance of `UBKitNotificationNameBuilder` for chaining.
    @discardableResult func setId(_ id: String) -> UBKitNotificationNameBuilder {
        self.id = id
        return self
    }
    
    /// Sets the method component for the notification name.
    /// - Parameter method: The method string to include.
    /// - Returns: The current instance of `UBKitNotificationNameBuilder` for chaining.
    @discardableResult func setMethod(_ method: String) -> UBKitNotificationNameBuilder {
        self.method = method
        return self
    }
    
    /// Builds the `Notification.Name` by combining the path, id, and method components.
    /// - Returns: A `Notification.Name` object created from the combined components.
    @discardableResult func build() -> Notification.Name {
        
        /// Array to hold the parts of the notification name.
        var parts: [String] = []
        
        /// Append path if it exists.
        if let path {
            parts.append(path)
        }
        
        /// Append id if it exists.
        if let id {
            parts.append(id)
        }
        
        /// Append method if it exists.
        if let method {
            parts.append(method)
        }
        
        /// Join the parts with underscores and return as `Notification.Name`.
        return .init(parts.joined(separator: "_"))
    }
}
