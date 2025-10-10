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
                List{
                    ForEach (vm.foodsFindedByModel) { food in
                        HStack{
                            Text("\(food.identifier)")
                                .font(.default)
                            Spacer()
                            Text("\(food.confidence * 100) %")
                                .font(.caption)
                        }
                    }
                }
                .padding()
                
                List{
                    ForEach (vm.tacoResults) { taco in
                        HStack{
                            Text("\(taco.nome)")
                                .font(.default)
                            Spacer()

                            VStack{
                                HStack{
                                    Text("Calories")
                                    Spacer()
                                    Text("\(String(format: "%.1f", taco.energiaKcal)) Kcal")
                                }

                                
                                HStack{
                                    Text("Proteinas")
                                    Spacer()
                                    Text("\(String(format: "%.1f", taco.proteina)) Kcal")
                                }
                                
                                
                                HStack{
                                    Text("Lipideos")
                                    Spacer()
                                    Text("\(String(format: "%.1f", taco.lipideos)) Kcal")
                                }
                                
                                
                                HStack{
                                    Text("Carbos")
                                    Spacer()
                                    Text("\(String(format: "%.1f", taco.carboidratos)) Kcal")
                                }
                            }
                            .frame(maxWidth: 150)
                            .font(.caption)
                        }
                    }
                }
                
                
            }
            .bold()
            .foregroundStyle(.white)
            .background(.black)
            
            
            Spacer()
        }
        .background(.white)
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
