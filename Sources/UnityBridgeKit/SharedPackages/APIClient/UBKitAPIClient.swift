//
//  UBKitAPIClient.swift
//  UnityBridgeKit
//
//  Created by Tuan on 11/1/25.
//

@preconcurrency import Foundation
import Combine
import Logging
import Factory

public final class UBKitAPIClient: @unchecked Sendable {
    
    // MARK: - Dependencies
    
    @ObservationIgnored @Injected(\.logger) private var logger
    private let observerQueue = DispatchQueue(label: "com.unityBridgeKit.ui.notification.queue", attributes: .concurrent)
    private var observers: [String: any NSObjectProtocol] = [:]
    
    // MARK: - Configuration
    
    private let logHandlers: [LogHandler]
    
    // MARK: - Initializers
    
    public init(
        logHandlers: [LogHandler] = [
            StreamLogHandler.standardOutput(label: UBKitConfiguration.loggingLabel)
        ]
    ) {
        self.logHandlers = logHandlers
        
        LoggingSystem.bootstrap { label in
            return MultiplexLogHandler(logHandlers)
        }
    }
}

// MARK: - UBKitAPIClientProtocol -

extension UBKitAPIClient: UBKitAPIClientProtocol {
    public func request(target: any UBKitTargetType) async throws -> Data {
        logger.info("Calling method \(#function) with target \(target)")
        
        let requestID = target.id
       
        
        removeObserverIfNeeded(for: requestID)
        sendingRequestToUnity(path: target.path, id: target.id, method: target.method.rawValue, encodedRequestJSONData: target.encodedToJSONString())
        
        return try await  withCheckedThrowingContinuation { continuation in
            
            let observer = NotificationCenter.default.addObserver(forName: target.notificationName, object: nil, queue: nil) { [weak self] notification in
                
                guard let self else { return }
                
                guard let userInfo = notification.userInfo else {
                    self.removeObserverIfNeeded(for: requestID)
                    continuation.resume(with: .failure(UBKitAPIClientError.receivedInvalidData))
                    return
                }
                
                guard let id = userInfo["id"] as? String, id == requestID else {
                    return 
                }
                
                guard let jsonData = userInfo["data"] as? String else {
                    self.removeObserverIfNeeded(for: requestID)
                    continuation.resume(with: .failure(UBKitAPIClientError.receivedInvalidData))
                    return
                }
                
                let copiedTarget = target
                self.logger.info("Received json data for target: \(copiedTarget): \(jsonData)")
                
                guard let data = jsonData.data(using: .utf8) else {
                    self.removeObserverIfNeeded(for: requestID)
                    continuation.resume(with: .failure(UBKitAPIClientError.receivedInvalidData))
                    return
                }
                
                self.removeObserverIfNeeded(for: requestID)
                continuation.resume(with: .success(data))
            }
            
            observerQueue.async(flags: .barrier) { [weak self] in
                guard let self else { return }
                self.observers[requestID] = observer
            }
        }
    }
    
    public func requestWithoutWaitingResponse(target: any UBKitTargetType) async throws {
        fatalError("")
    }
    
    public func listen(onEventName name: String) -> AnyPublisher<Data, any Error> {
        fatalError("")
    }
}

// MARK: - Privates -

private extension UBKitAPIClient {
    
    // Helper function to remove observer safely
    
    private func removeObserverIfNeeded(for requestID: String) {
        observerQueue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            if let observer = self.observers.removeValue(forKey: requestID) {
                NotificationCenter.default.removeObserver(observer)
            }
        }
    }
    
    func sendingRequestToUnity(path: String, id: String, method: String, encodedRequestJSONData: String) {
        unityBrigeKitSendingRequestToUnityUsingCallback(path: path, id: id, method: method, encodedRequestJSONData: encodedRequestJSONData)
    }
}

// MARK: - Global Data for handling unity data flow -

public typealias CallbackDelegateType = @convention(c) (UnsafePointer<CChar>, UnsafePointer<CChar>, UnsafePointer<CChar>, UnsafePointer<CChar>) -> Void
nonisolated(unsafe) var sCallbackDelegate: CallbackDelegateType? = nil


/// Declared in C# as: static extern void SetNativeCallback(CallbackDelegate callback);
@_cdecl("UnityBridgeKitSetNativeCallback")
public func unityBridgeKitSetNativeCallback(_ delegate: CallbackDelegateType) {
    
    let logger = Container.shared.logger.resolve()
    
    logger.info("Calling \(#function) with delegate \(String(describing: delegate))")
    sCallbackDelegate = delegate
}

@_cdecl("UnityBridgeKitSendingResponseData")
public func unityBrigeKitUnityReturnedResponseData(_ path: UnsafePointer<CChar>, id: UnsafePointer<CChar>, method: UnsafePointer<CChar>, data: UnsafePointer<CChar>) {
    
    let notificationName = UBKitNotificationNameBuilder()
        .setPath(path.toString())
        .setId(id.toString())
        .setMethod(method.toString())
        .build()
    
    NotificationCenter.default.post(
        name: notificationName,
        object: nil, userInfo: [
            "id": id.toString(),
            "data": data.toString()
        ]
    )
}

func unityBrigeKitSendingRequestToUnityUsingCallback(path: String, id: String, method: String, encodedRequestJSONData: String) {

    let logger = Container.shared.logger.resolve()
    
    guard let sCallbackDelegate else {
        logger.error("Calling \(#function) but gotten the sCallbackDelegate as nil")
        return
    }
    
    guard let pathPointer = path.toPointer(),
          let idPointer = id.toPointer(),
          let methodPointer = method.toPointer(),
          let encodedRequestJSONDataPointer = encodedRequestJSONData.toPointer() else {
        logger.error("Calling \(#function) but gotten nil pointer")
        return
    }
    
    logger.info("Calling \(#function) starting....")
    sCallbackDelegate(pathPointer, idPointer, methodPointer, encodedRequestJSONDataPointer)
}
