//
//  Item.swift
//  Brewbuddy
//
//  Created by 吴炜 on 3/16/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
