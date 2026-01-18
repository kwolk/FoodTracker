//
//  Price.swift
//  FoodTracker
//
//  Created by Samuel Corke on 16/01/2026.
//

import Foundation


struct Price: Codable, Identifiable, Hashable {
    let id          : UUID
    var regularPrice: Decimal
    var specialPrice: Decimal?  // there may not be a special price
    var date        : Date
    
    init(regularPrice: Decimal, specialPrice: Decimal? = nil, date: Date = .now) {
        self.id             = UUID()
        self.regularPrice   = regularPrice
        self.specialPrice   = specialPrice
        self.date           = date
    }
}
