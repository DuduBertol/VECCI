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
                if let img = $vm.selectedImage.wrappedValue {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                } else {
                    Rectangle()
                        .foregroundStyle(.gray)
                        .frame(height: 300)
                        .cornerRadius(12)
                        .overlay(Text("preview"))
                }
            }
            
//            Text($vm.resultText.wrappedValue)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal)

            PhotosPicker("Choose Image", selection: $vm.selectedItem, matching: .images)
                .buttonStyle(.borderedProminent)
            
            Button {
                guard let img = $vm.selectedImage.wrappedValue else { return }
//                vm.classify(uiImage: img)
                vm.classifyImageandFetchResults(uiImage: img)
                
                canProcessTACO = true
            } label: {
                Text("Process Image")
            }
            .buttonStyle(.borderedProminent)
            
            Button {
                vm.fetchIngredientsFromImage()
            } label: {
                Text("Get Ingredients from Image")
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canProcessTACO)

            Button {
                vm.analyseMainIngredientOnTACO()
            } label: {
                Text("Analyse Ingredient on TACO")
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canProcessTACO)

            
            VStack{
                List{
                    ForEach (vm.results) { food in
                        HStack{
                            Text("\(food.identifier)")
                                .font(.title2)
                            Spacer()
                            Text("\(food.confidence * 100) %")
                                .font(.default)
                        }
                    }
                }
                
//                Text($vm.testName.wrappedValue)
//                    .font(Font.caption.bold())
                
//                List {
//                    ForEach () { _ in
//                    }
//                }
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

