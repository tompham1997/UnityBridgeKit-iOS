//
//  DI+Registration.swift
//  UnityBridgeKit
//
//  Created by Tuan on 11/1/25.
//

import Factory
import Logging

extension Container {
    
    var logger: Factory<Logger> {
        Factory(self) {
            Logger(label: UBKitConfiguration.loggingLabel)
        }
        .scope(.singleton)
    }
}
