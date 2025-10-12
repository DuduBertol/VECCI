//
//  Food.swift
//  FoodScanner
//
//  Created by Eduardo Bertol on 12/10/25.
//

import Foundation

struct Food: Identifiable, Codable {
    let id: UUID
    var identifier: String
    var confidence: Float
    
    init(
        identifier: String,
        confidence: Float
    ){
        self.id = UUID()
        self.identifier = identifier
        self.confidence = confidence
    }
    
    func getName() -> String {
        identifier
    }
}
