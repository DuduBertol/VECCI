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
    
//    private var model: VNCoreMLModel?
    
    private var coreMLService = CoreMLService()
    
//    private var formatNameFMService = FormatNameFMService()
    private var tacoService = TacoService()
    private var foundationModelService = FoundationModelService()
    
    @Published var selectedItem: PhotosPickerItem?
    @Published var selectedImage: UIImage?
//    @Published var foodNameResult: String = ""
    
    @Published var foodsFindedByModel: [Food] = []
    private var mainFoodAnalysis: FoodAnalysis?
    @Published var tacoResults: [TacoItem] = []
    
//    @Published var testName: String = "chicken_curry"
    
//    @Published var resultIdentifiers: [String] = []
//    @Published var resultConfidences: [Float] = []

    
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
//        Task{
            do{

                foodsFindedByModel = try coreMLService.classify(uiImage)
            } catch {
                print("Algum erro na classificação")
                print(error.localizedDescription)
            }
//        }
    }
    
//    func simulatedPromt() {
//        Task{
//            do {
//                testName = try await formatNameFMService.formatName(testName)
//            } catch {
//                testName = "Failed to answer the question: \(error.localizedDescription)"
//            }
//        }
//    }
    
    private func fetchIngredientsFromImage() async {
        guard let foodName = foodsFindedByModel.first?.identifier else { return }
        
    
//        Task {
            do{
                let result = try await foundationModelService.analyzeFood(foodName)
                print("INGREDIENTES:")
                print(result)
                
                mainFoodAnalysis = result
                
            } catch {
                print(error.localizedDescription)
            }
//        }
    }
    
    private func analyseMainIngredientOnTACO() {
        guard let mainFoodAnalysis else { return }
        
//        guard let mainIngredient = mainFoodAnalysis?.ingredients[0] else {
//            print("Main ingredient nil")
//            return
//        }
        for ingredient in mainFoodAnalysis.ingredients {
            guard let tacoItem: TacoItem = tacoService.findClosest(ingredient) else { print("Nil. Não TacoItem"); return}
            
            tacoResults.append(tacoItem)
        }
        
        
//        guard let result: TacoItem = tacoService.findClosest(mainIngredient) else { print("Nil. Não TacoItem"); return}
        
        print("TACO ITEMS")
        print(tacoResults)
    }
    
    func doAllInSequence(foodImage: UIImage) {
            
        classifyImageandFetchResults(uiImage: foodImage)
        
        Task {
            await fetchIngredientsFromImage()
            
            analyseMainIngredientOnTACO()
//            DispatchQueue.main.async{
                
//            }
        }
        
        
    }
}
