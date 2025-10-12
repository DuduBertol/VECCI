//
//  VisionView.swift
//  FoodScanner
//
//  Created by Eduardo Bertol on 11/10/25.
//

import SwiftUI
import PhotosUI

struct VisionView: View {
    
    @StateObject private var vm = VisionViewModel()
    
    @State private var isDisabledAnalyseButton: Bool = true
    @State private var showInfoSheet: Bool = false
    
    var body: some View {
        NavigationStack{
            
            ZStack{
                
                //MARK: - IMAGEM
                VStack{
                    if let img = vm.selectedImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: 405, maxHeight: 400)
                            .cornerRadius(16)
                            .shadow(radius: 4)
                    } else {
                        Rectangle()
                            .foregroundStyle(.gray.opacity(0.5))
                            .frame(width: 405, height: 400)
                            .cornerRadius(16)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                            )
                    }
                    Spacer()
                }
                .ignoresSafeArea()
                
                //MARK: - CONTENT
                VStack{
                    VStack{
                        Rectangle()
                            .foregroundStyle(.clear)
                    }
                    .frame(height: 300)
                    
                    if vm.foodTotalTacoResult.translatedName != "None"{
                        VStack(alignment: .center, spacing: 16){
                            VStack{
                                Text($vm.foodTotalTacoResult.translatedName.wrappedValue)
                                    .font(.title2)
                                    .bold()
                                    .padding(.vertical)
                                    .padding(.horizontal, 16)
                                    .glassEffect()
                                Text("esta é uma estimativa hipotética (\(String(format: "%.1f", $vm.foodTotalTacoResult.confidence.wrappedValue * 100)))% para - \(String(format: "%.1f", $vm.foodTotalTacoResult.totalWeight_g.wrappedValue)) g")
                                    .foregroundStyle(.opacity(0.25))
                                    .font(.caption)
                            }
                            VStack{
                                NumberStatsRowView(title: "Calorias", amount: $vm.foodTotalTacoResult.calories_kcal.wrappedValue, unit: "Kcal")
                                NumberStatsRowView(title: "Proteínas", amount: $vm.foodTotalTacoResult.proteins_g.wrappedValue)
                                NumberStatsRowView(title: "Carboidratos", amount: $vm.foodTotalTacoResult.carbohydrates_g.wrappedValue)
                                NumberStatsRowView(title: "Gorduras", amount: $vm.foodTotalTacoResult.fats_g.wrappedValue)
                                NumberStatsRowView(title: "Fibras", amount: $vm.foodTotalTacoResult.fibers_g.wrappedValue)
                            }
                        }
                        .padding(.horizontal, 32)
                        
                    } else {
                        VStack{
                            Text("Adicione uma foto")
                                .font(.title2)
                                .bold()
                                .padding(.vertical)
                                .padding(.horizontal, 16)
                                .glassEffect()
                                .glassEffectTransition(.identity)
                            Text("então clique no 'olho' para analisar.")
                                .foregroundStyle(.opacity(0.5))
                                .font(.footnote)
                            Spacer()
                            
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    Spacer()
                }
                
                //MARK: - LOADING
                VStack{
                    Spacer()
                    if $vm.isLoading.wrappedValue {
                        HStack{
                            Spacer()
                            SpinningLoader()
                        }
                        .padding(.trailing, 32)
                    }
                }
                .offset(y: 32)
            }
            
            
            //MARK: - TOP TOOLBAR
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button{
                        showInfoSheet = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu(){
                        Menu("Modelo"){
                            Button("FoodClassifier (101 Classes)"){
                                vm.setMLModel(to: .foodClassifier)
                            }
                            Button("VECCI (174 Classes)"){
                                vm.setMLModel(to: .vecci)
                            }
                        }
                    } label: {
                        Image(systemName: "gear")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    
                }
            }
            
            //MARK: - BOTTOM TOOLBAR
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    PhotosPicker(selection: $vm.selectedItem, matching: .images){
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 19, weight: .semibold))
                    }
                    .buttonStyle(.glassProminent)
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        guard let img = vm.selectedImage else { return }
                        vm.doAllInSequence(foodImage: img)
                    } label: {
                        Image(systemName: "eye")
                            .font(.system(size: 19, weight: .semibold))
                    }
                    .disabled(isDisabledAnalyseButton)
                    .buttonStyle(.glassProminent)
                }
            }
        }
        //MARK: - VIEW MODIFIERS
        .onChange(of: vm.selectedImage) { oldValue, newValue in
            guard newValue != nil else { return }
            
            isDisabledAnalyseButton = false
        }
        .onChange(of: vm.selectedItem) { oldValue, newValue in
            guard let newValue else { return }
            vm.getPhotoItemAsImage(item: newValue)
        }
        .sheet(isPresented: $showInfoSheet) {
            InfoSheet(food: $vm.foodTotalTacoResult)
                .presentationDetents([
                    .height(180), .medium, .large
                ])
        }
    }
}

#Preview {
    VisionView()
}

