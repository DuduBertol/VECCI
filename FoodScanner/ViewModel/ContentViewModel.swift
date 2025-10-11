//
//  ContentViewModel.swift
//  FoodScanner
//
//  Created by Eduardo Bertol on 10/10/25.
//


import Foundation
import Combine
import CoreML
import Vision
import SwiftUI
import PhotosUI

class ContentViewModel: ObservableObject {
    
    private var coreMLService = CoreMLService()
    private var foundationModelService = FoundationModelService()
    private var tacoService = TacoService()
    
    @Published var selectedItem: PhotosPickerItem?
    @Published var selectedImage: UIImage?
    
    @Published var foodsFindedByModel: [Food] = []
    private var mainFoodAnalysis: FoodAnalysis?
    @Published var tacoResults: [TacoItem] = []
    
    @Published var foodTotalTacoResult: TacoItem = .mockEmpty()
    
    func getPhotoItemAsImage(item: PhotosPickerItem) {
        Task {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                    print("Imagem selecionada com sucesso.")
                }
            } catch {
                print("Algum erro na foto")
                print(error.localizedDescription)
            }
        }
    }
    
    private func classifyImageandFetchResults(uiImage: UIImage) {
        
        do{
            
            foodsFindedByModel = try coreMLService.classify(uiImage)
        } catch {
            print("Algum erro na classificação")
            print(error.localizedDescription)
        }
        
    }
    
    private func fetchIngredientsFromImage() async {
        guard let foodName = foodsFindedByModel.first?.identifier else { return }
        
        
        do{
            let result = try await foundationModelService.analyzeFood(foodName)
            print("INGREDIENTES:")
            print(result)
            
            mainFoodAnalysis = result
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func analyseMainIngredientOnTACO() {
        guard let mainFoodAnalysis else { return }
        
        for ingredient in mainFoodAnalysis.ingredients {
            guard let tacoItem: TacoItem = tacoService.findClosest(ingredient) else { print("Nil. Não TacoItem"); return}
            
            tacoResults.append(tacoItem)
        }
        
        print("TACO ITEMS")
        print(tacoResults)
    }
    
    func doAllInSequence(foodImage: UIImage) {
        
        classifyImageandFetchResults(uiImage: foodImage)
        
        Task {
            await fetchIngredientsFromImage()
            
            analyseMainIngredientOnTACO()
        }
    }
    
    func calculateTotalTacoResult() {
        guard let foodName = foodsFindedByModel.first?.identifier else { return }
        var totalCalories: Double = 0
        var totalProtein: Double = 0
        var totalCarbohydrates: Double = 0
        var totalFats: Double = 0
        
        for item in tacoResults {
            totalCalories += item.energiaKcal
            totalProtein += item.proteina
            totalCarbohydrates += item.carboidratos
            totalFats += item.lipideos
        }
        
        foodTotalTacoResult = TacoItem(
            nome: foodName,
            energiaKcal: totalCalories,
            proteina: totalProtein,
            lipideos: totalFats,
            carboidratos: totalCarbohydrates
        )
        
    }
}
