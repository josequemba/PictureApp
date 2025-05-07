//
//  Item.swift
//  PictureApp
//
//  Created by Jose Quemba on 5/7/25.
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
