//
//  Item.swift
//  fridge-control
//
//  Created by Felipe Giacomini Cocco on 18/01/26.
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
