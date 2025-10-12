//
//  SpinningLoader.swift
//  FoodScanner
//
//  Created by Eduardo Bertol on 12/10/25.
//


import SwiftUI
struct SpinningLoader: View {
    @State private var rotationDegrees: Double = 0
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7) // Creates an arc
            .stroke(Color.blue, lineWidth: 2)
            .frame(width: 10, height: 10)
            .rotationEffect(.degrees(rotationDegrees))
            .onAppear {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    rotationDegrees = 360 // Animate rotation
                }
            }
    }
}
