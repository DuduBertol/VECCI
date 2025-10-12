//
//  TextStatsRowView.swift
//  FoodScanner
//
//  Created by Eduardo Bertol on 12/10/25.
//


import SwiftUI
struct TextStatsRowView: View {
    
    var title: String
    var content: String
    
    
    var body: some View {
        HStack{
            Text(title)
                .font(.body)
                .frame(width: 175)
                .padding(.vertical, 12)
                .glassEffect()
            
            Spacer()
            
            Text(content)
                .font(.subheadline)
                .bold()
                .frame(width: 100)
                .padding(.vertical, 12)
                .glassEffect()
        }
    }
}

