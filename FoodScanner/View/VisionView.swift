//
//  VisionView.swift
//  FoodScanner
//
//  Created by Eduardo Bertol on 11/10/25.
//

import SwiftUI
import PhotosUI

struct VisionView: View {
    
    @StateObject private var vm = ContentViewModel()
    
    @State private var isDisabledAnalyseButton: Bool = true
    
    var body: some View {
        ZStack{
            VStack{
                VStack{
                    if let img = vm.selectedImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(maxHeight: 400)
                            .cornerRadius(16)
                            .shadow(radius: 4)
                    } else {
                        Rectangle()
                            .foregroundStyle(.gray.opacity(0.5))
                            .frame(width: 400, height: 400)
                            .cornerRadius(16)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                            )
                    }
                }
                .ignoresSafeArea()
    //            .border(.blue)
                
                if vm.foodTotalTacoResult.translatedName != "None"{
                    VStack(alignment: .center, spacing: 16){
                        VStack{
                            Text($vm.foodTotalTacoResult.translatedName.wrappedValue)
                                .font(.title2)
                                .bold()
                                .padding(.vertical)
                                .padding(.horizontal, 16)
                                .glassEffect()
                            Text("esta é uma estimativa hipotética para - \(String(format: "%.1f", $vm.foodTotalTacoResult.totalWeight_g.wrappedValue)) g")
                                .foregroundStyle(.opacity(0.25))
                                .font(.footnote)
                                
                        }
                        
                        VStack{
                            StatsRowView(title: "Calorias", amount: $vm.foodTotalTacoResult.calories_kcal.wrappedValue, unit: "Kcal")
                            StatsRowView(title: "Proteínas", amount: $vm.foodTotalTacoResult.proteins_g.wrappedValue)
                            StatsRowView(title: "Carboidratos", amount: $vm.foodTotalTacoResult.carbohydrates_g.wrappedValue)
                            StatsRowView(title: "Gorduras", amount: $vm.foodTotalTacoResult.fats_g.wrappedValue)
                            StatsRowView(title: "Fibras", amount: $vm.foodTotalTacoResult.fibers_g.wrappedValue)
                        }
                        
                        
                    }
                    .offset(y: -54)
                    .padding(.horizontal, 32)
                } else {
                    VStack{
                        Text("Upload a food photo")
                            .font(.title2)
                            .bold()
                            .padding(.vertical)
                            .padding(.horizontal, 16)
                            .glassEffect()
                            .glassEffectTransition(.identity)
                        Text("then click in the 'eye' to Inspect.")
                            .foregroundStyle(.opacity(0.5))
                            .font(.footnote)
                            
                    }
                    .offset(y: -54)
                    .padding(.horizontal, 16)
                }
    //            .border(.red)
                Spacer()
                
            }
            VStack{
                Spacer()
                ZStack{
                    HStack{
                        PhotosPicker(selection: $vm.selectedItem, matching: .images){
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 19, weight: .semibold))
                        }
                        .glassEffect()
//                        .glassEffectTransition(.materialize)
                        .buttonStyle(.borderedProminent)
                        
                        Button {
                            guard let img = vm.selectedImage else { return }
                            vm.doAllInSequence(foodImage: img)
                        } label: {
                            Image(systemName: "eye")
                                .font(.system(size: 19, weight: .semibold))
                        }
                        .disabled(isDisabledAnalyseButton)
                        .glassEffect()
//                        .glassEffectTransition(.identity)
                        .buttonStyle(.borderedProminent)
                    }
                    if $vm.isLoading.wrappedValue {
                        HStack{
                            Spacer()
                            SpinningLoader()
                        }
                        .padding(.trailing, 32)
                    }
                }
            }
        }
        .onChange(of: vm.selectedImage) { oldValue, newValue in
            guard newValue != nil else { return }
            
            isDisabledAnalyseButton = false
        }
        .onChange(of: vm.selectedItem) { oldValue, newValue in
            guard let newValue else { return }
            vm.getPhotoItemAsImage(item: newValue)
        }
    }
}

#Preview {
    VisionView()
}

struct StatsRowView: View {
    
    var title: String = "None"
    var amount: Double = 0
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
