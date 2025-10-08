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

            PhotosPicker("Escolher foto", selection: $vm.selectedItem, matching: .images)
                .buttonStyle(.borderedProminent)
            
            Button {
                guard let img = $vm.selectedImage.wrappedValue else { return }
                vm.classify(uiImage: img)
            } label: {
                Text("Processar Imagem")
            }
            .buttonStyle(.borderedProminent)

            Text($vm.resultText.wrappedValue)
                .font(Font.largeTitle.bold())
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

