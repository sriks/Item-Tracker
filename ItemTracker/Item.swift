//
//  Item.swift
//  ItemTracker
//
//  Created by Srikanth on 17/10/2025.
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
