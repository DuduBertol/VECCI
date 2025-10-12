//
//  ContentView.swift
//  FoodScanner
//
//  Created by Eduardo Bertol on 07/10/25.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    
    @StateObject private var vm = ContentViewModel()
    
    @State private var canProcessTACO: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView{
                VStack{
                    if let img = vm.selectedImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .shadow(radius: 4)
                    } else {
                        Rectangle()
                            .foregroundStyle(.gray)
                            .cornerRadius(12)
                            .overlay(Text("preview"))
                    }
                }
                
                PhotosPicker("Choose Image", selection: $vm.selectedItem, matching: .images)
                    .buttonStyle(.borderedProminent)
                
                Button {
                    guard let img = vm.selectedImage else { return }
                    vm.doAllInSequence(foodImage: img)
                } label: {
                    Text("Process Image")
                }
                .buttonStyle(.borderedProminent)
                
                
                VStack{
                    HStack{
                        Text("\($vm.foodTotalTacoResult.translatedName.wrappedValue)")
                            .font(.default)
                        Spacer()
                        Text("\(String(format: "%.1f", $vm.foodTotalTacoResult.confidence.wrappedValue * 100)) %")
                            .font(.caption)
                        Text("\(String(format: "%.1f", $vm.foodTotalTacoResult.totalWeight_g.wrappedValue)) g")
                            .font(.caption)
                    }
                    
                    VStack{
                        HStack{
                            Text("Calorias")
                            Spacer()
                            Text("\(String(format: "%.1f", $vm.foodTotalTacoResult.calories_kcal.wrappedValue)) Kcal")
                        }
                        
                        
                        HStack{
                            Text("Proteínas")
                            Spacer()
                            Text("\(String(format: "%.1f", $vm.foodTotalTacoResult.proteins_g.wrappedValue)) g")
                        }
                        
                        HStack{
                            Text("Carboidratos")
                            Spacer()
                            Text("\(String(format: "%.1f", $vm.foodTotalTacoResult.carbohydrates_g.wrappedValue)) g")
                        }

                        
                        HStack{
                            Text("Lipideos")
                            Spacer()
                            Text("\(String(format: "%.1f", $vm.foodTotalTacoResult.fats_g.wrappedValue)) g")
                        }

                        HStack{
                            Text("Fibras")
                            Spacer()
                            Text("\(String(format: "%.1f", $vm.foodTotalTacoResult.fibers_g.wrappedValue)) g")
                        }
                        
                        
                    }
                    .frame(maxWidth: 150)
                    .font(.caption)
                    
                }
                .bold()
                
                
                Spacer()
            }}
        .padding()
        .onChange(of: vm.selectedItem) { oldValue, newValue in
            guard let newValue else { return }
            vm.getPhotoItemAsImage(item: newValue)
        }
    }
    
    
}

#Preview {
    ContentView()
}

