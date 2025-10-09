//
//  ContentViewModel.swift
//  FoodScanner
//
//  Created by Eduardo Bertol on 07/10/25.
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
    
    @Published var results: [Food] = []
    @Published var mainFoodAnalysis: FoodAnalysis?
    
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
    
    func classifyImageandFetchResults(uiImage: UIImage) {
        Task{
            do{

                results = try coreMLService.classify(uiImage)
            } catch {
                print("Algum erro na classificação")
                print(error.localizedDescription)
            }
        }
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
    
    func fetchIngredientsFromImage() {
        guard let foodName = results.first?.identifier else { return }
        
    
        Task {
            do{
                let result = try await foundationModelService.analyzeFood(foodName)
                print("INGREDIENTES:")
                print(result)
                
                mainFoodAnalysis = result
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func analyseMainIngredientOnTACO() {
        guard let mainIngredient = mainFoodAnalysis?.ingredients[0] else {
            print("Main ingredient nil")
            return
        }
        
        guard let result: TacoItem = tacoService.findClosest(mainIngredient) else { print("Nil. Não TacoItem"); return}
        
        print("TACO ITEM")
        print(result)
    }
}
