//
//  MockTarget.swift
//  UnityBridgeKit
//
//  Created by Tuan on 10/1/25.
//

import Foundation
@testable import UnityBridgeKit

struct MockTarget: UBKitTargetType  {
    
    let id: String
    
    let path: String
    
    let parameters: [String : Any]?
    
    let method: UBKitRequestMethod
}
