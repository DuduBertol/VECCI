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
    private var formatNameService = FormatNameFMService()
    private var tacoService = TacoService()
        
    private var foodsFindedByModel: [Food] = []
    private var mainFoodAnalysis: FoodAnalysis?
    private var tacoResults: [(TacoItem, weight: Double)] = []
    
    @Published var selectedItem: PhotosPickerItem?
    @Published var selectedImage: UIImage?
    @Published var foodTotalTacoResult: FinalFoodAnalysed = .mockEmpty()
    
    @Published var isLoading: Bool = false
    
    
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
        
        do {
            foodsFindedByModel = try coreMLService.classify(uiImage)
        } catch {
            print("Algum erro na classificação")
            print(error.localizedDescription)
        }
        
    }
    
    private func fetchIngredientsFromImage() async {
        guard let food = foodsFindedByModel.first else { return }
        foodTotalTacoResult.modelName = food.identifier
        foodTotalTacoResult.confidence = food.confidence
        
        do{
            let translatedFoodName = try await formatNameService.formatName(foodTotalTacoResult.modelName)
            foodTotalTacoResult.translatedName = translatedFoodName
            
            let result = try await foundationModelService.analyzeFood(translatedFoodName)
            mainFoodAnalysis = result
            
            print("INGREDIENTES:")
            print(result)
                    
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func analyseMainIngredientOnTACO() {
        guard let mainFoodAnalysis else { return }
        
        for ingredient in mainFoodAnalysis.ingredients {
            guard let tacoItem: TacoItem = tacoService.smartSearch(ingredient) else { print("Nenhum TacoItem encontrado para: \(ingredient)")
                continue
            }
            
            let weight = mainFoodAnalysis.estimatedWeight[ingredient] ?? 0
            tacoResults.append((tacoItem, weight: weight))
        }
        
        print("✅ TACO ITEMS ENCONTRADOS: \(tacoResults.count)")
        tacoResults.forEach { item, weight in
            print("  - \(item.nome): \(weight)g")
        }
    }
    
    private func calculateFinalFoodAnalysed() {
        
        
        var totalCalories: Double = 0
        var totalProtein: Double = 0
        var totalCarbohydrates: Double = 0
        var totalFats: Double = 0
        var totalFibers: Double = 0
        
        var totalWeight: Double = 0
        
        
        for (tacoItem, weight) in tacoResults {
            let calculatedTacoItem = tacoItem.calculateProportions(weight: weight)
            
            totalCalories       += calculatedTacoItem.energiaKcal
            totalProtein        += calculatedTacoItem.proteina
            totalCarbohydrates  += calculatedTacoItem.carboidratos
            totalFats           += calculatedTacoItem.lipideos
            totalFibers         += calculatedTacoItem.fibras

            totalWeight += weight
            print(totalWeight)
        }
        
        foodTotalTacoResult.calories_kcal   = totalCalories
        foodTotalTacoResult.proteins_g      = totalProtein
        foodTotalTacoResult.carbohydrates_g = totalCarbohydrates
        foodTotalTacoResult.fats_g          = totalFats
        foodTotalTacoResult.fibers_g        = totalFibers

        foodTotalTacoResult.ingredients = mainFoodAnalysis?.ingredients ?? []
        foodTotalTacoResult.totalWeight_g  = totalWeight
    
    }
    
    func doAllInSequence(foodImage: UIImage) {
        cleanUp()
        
        foundationModelService.setupSession()
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        Task {
            ///CoreML
            classifyImageandFetchResults(uiImage: foodImage)
        
            ///FoundationModel
            await fetchIngredientsFromImage()
            
            ///TACO
            analyseMainIngredientOnTACO()
            
            ///Final Sum
            calculateFinalFoodAnalysed()
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    private func cleanUp() {
        mainFoodAnalysis = nil
        tacoResults.removeAll()
        foundationModelService.quitSession()
    }
}


struct FinalFoodAnalysed {
    let id = UUID()

    var modelName: String
    var translatedName: String
    
    var confidence: Float
    var ingredients: [String]
    
    var totalWeight_g: Double
    var calories_kcal: Double
    var proteins_g: Double
    var carbohydrates_g: Double
    var fats_g: Double
    var fibers_g: Double
}

extension FinalFoodAnalysed {
    static func mockEmpty() -> Self {
        FinalFoodAnalysed(
            modelName: "None",
            translatedName: "None",
            confidence: 0,
            ingredients: [],
            totalWeight_g: 0,
            calories_kcal: 0,
            proteins_g: 0,
            carbohydrates_g: 0,
            fats_g: 0,
            fibers_g: 0
        )
    }
}
