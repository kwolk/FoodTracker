//
//  Foodstuffs.swift
//  FoodTracker
//
//  Created by Samuel Corke on 16/01/2026.
//

import Foundation
import SwiftData

@Model
final class Foodstuffs: ObservableObject, Identifiable, Codable {
    @Attribute(.unique) var id: UUID
    @Attribute var name     : String
    @Attribute var brand    : String
    @Attribute var weight   : Double
    @Attribute var barcode  : String
    @Attribute var date     : Date
    @Attribute var prices   : [Price]
    @Attribute var photos   : [Photo]
    @Attribute var reviews  : [Review]
    @Attribute var enjoy    : Bool
    @Attribute var health   : Bool

    init(id: UUID = UUID(),
         name   : String    = "",
         brand  : String    = "",
         weight : Double    = 0.0,
         barcode: String    = "",
         date   : Date      = .now,
         prices : [Price]   = [],
         photos : [Photo]   = [],
         reviews: [Review]  = [],
         enjoy  : Bool      = false,
         health : Bool      = false) {
        self.id         = id
        self.name       = name
        self.brand      = brand
        self.weight     = weight
        self.barcode    = barcode
        self.date       = date
        self.prices     = prices
        self.photos     = photos
        self.reviews    = reviews
        self.enjoy      = enjoy
        self.health     = health
    }

    
    enum CodingKeys: String, CodingKey {
        case id, name, weight, brand, barcode, date, prices, photos, reviews, enjoy, health
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id      = try container.decode(UUID.self,       forKey: .id)
        let name    = try container.decode(String.self,     forKey: .name)
        let brand   = try container.decode(String.self,     forKey: .brand)
        let weight  = try container.decode(Double.self,     forKey: .weight)
        let barcode = try container.decode(String.self,     forKey: .barcode)
        let date    = try container.decode(Date.self,       forKey: .date)
        let prices  = try container.decode([Price].self,    forKey: .prices)
        let photos  = try container.decode([Photo].self,    forKey: .photos)
        let reviews = try container.decode([Review].self,   forKey: .reviews)
        let enjoy   = try container.decode(Bool.self,       forKey: .enjoy)
        let health  = try container.decode(Bool.self,       forKey: .health)
        self.init(id        : id,
                  name      : name,
                  brand     : brand,
                  weight    : weight,
                  barcode   : barcode,
                  date      : date,
                  prices    : prices,
                  photos    : photos,
                  reviews   : reviews,
                  enjoy     : enjoy,
                  health    : health)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id,        forKey: .id)
        try container.encode(name,      forKey: .name)
        try container.encode(brand,     forKey: .brand)
        try container.encode(weight,    forKey: .weight)
        try container.encode(barcode,   forKey: .barcode)
        try container.encode(date,      forKey: .date)
        try container.encode(prices,    forKey: .prices)
        try container.encode(photos,    forKey: .photos)
        try container.encode(reviews,   forKey: .reviews)
        try container.encode(enjoy,     forKey: .enjoy)
        try container.encode(health,    forKey: .health)
    }
    
    var currentPrice: Price? { prices.sorted { $0.date > $1.date }.first }
    
    
    func addPrice(regular: Decimal, special: Decimal? = nil, on date: Date = .now) {
        prices.append(Price(regularPrice: regular, specialPrice: special, date: date))
        prices.sort { $0.date > $1.date } // most recent first
    }
    
    var sortedReviews: [Review] {
        reviews.sorted { $0.date > $1.date }
    }

    func addReview(_ text: String, on date: Date = .now) {
        reviews.append(Review(text: text, date: date))
    }

}
