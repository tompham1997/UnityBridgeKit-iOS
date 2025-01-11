//
//  UBKitRequestMethod.swift
//  UnityBridgeKit
//
//  Created by Tuan on 11/1/25.
//

import Foundation

/// An enumeration representing the Unity Bridge request methods supported by UnityBridgeKit.
public enum UBKitRequestMethod: String, Sendable {
    
    /// Represents a Unity Bridge GET request, typically used for retrieving data.
    case get = "GET"
    
    /// Represents a Unity Bridge POST request, generally used for sending data.
    case post = "POST"
    
    /// Represents a Unity Bridge PUT request, often used to update or replace data.
    case put = "PUT"
    
    /// Represents a Unity Bridge DELETE request, used to delete data.
    case delete = "DELETE"
}
