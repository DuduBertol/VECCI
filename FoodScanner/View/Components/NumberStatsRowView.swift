//
//  NumberStatsRowView.swift
//  FoodScanner
//
//  Created by Eduardo Bertol on 12/10/25.
//


import SwiftUI
struct NumberStatsRowView: View {
    
    var title: String
    var amount: Double
    var unit: String = "g"
    
    
    var body: some View {
        HStack{
            Text(title)
                .font(.body)
                .frame(width: 175)
                .padding(.vertical, 12)
                .glassEffect()
            
            Spacer()
            
            Text("\(String(format: "%.1f", amount)) \(unit)")
                .font(.subheadline)
                .bold()
                .frame(width: 100)
                .padding(.vertical, 12)
                .glassEffect()
        }
    }
}

