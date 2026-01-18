//
//  Review.swift
//  FoodTracker
//
//  Created by Samuel Corke on 16/01/2026.
//

import Foundation


struct Review: Identifiable, Codable, Equatable {
    let id  : UUID
    var text: String
    var date: Date

    init(id: UUID = UUID(), text: String, date: Date = .now) {
        self.id     = id
        self.text   = text
        self.date   = date
    }
}
