//
//  UBKitAPIClientProtocol.swift
//  UnityBridgeKit
//
//  Created by Tuan on 11/1/25.
//

import Foundation
import Combine

/// Protocol defining the API client for UnityBridgeKit
public protocol UBKitAPIClientProtocol {
    
    /// Sends a request to the specified target and waits for a response.
    /// - Parameter target: The target of the request conforming to `UBKitTargetType`.
    /// - Returns: The raw `Data` returned from the target.
    /// - Throws: An error if the request fails.
    func request(target: UBKitTargetType) async throws -> Data
    
    /// Sends a request to the specified target without waiting for a response.
    /// - Parameter target: The target of the request conforming to `UBKitTargetType`.
    /// - Throws: An error if the request fails.
    func requestWithoutWaitingResponse(target: UBKitTargetType) async throws
    
    /// Subscribes to events with the specified name and listens for data updates.
    /// - Parameter name: The name of the event to listen to.
    /// - Returns: A `Publisher` emitting `Data` for the event or an `Error` if something goes wrong.
    func listen(onEventName name: String) -> AnyPublisher<Data, Error>
}
