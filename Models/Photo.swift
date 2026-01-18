//
//  Photo.swift
//  FoodTracker
//
//  Created by Samuel Corke on 16/01/2026.
//

import Foundation


struct Photo: Codable, Identifiable, Hashable {
    
    let id      : UUID
    var date    : Date
    var filename: String
    
    init(id: UUID = UUID(), date: Date = .now, filename: String) {
        self.id         = id
        self.date       = date
        self.filename   = filename
    }
}
