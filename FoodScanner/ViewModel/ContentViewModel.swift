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
    
    private var model: VNCoreMLModel?
    
//    private var coreMLService = CoreMLService()
    
    @Published var selectedItem: PhotosPickerItem?
    @Published var selectedImage: UIImage?
    @Published var resultText: String = ""
    
//    @Published var resultsDict: [String: Float] = [:]
    
    
    
    
    init() {
        setupModel()
    }
    
    
    func setupModel() {
        do {
//            let model = try VNCoreMLModel(for: FoodClassifier().model)
            self.model = try VNCoreMLModel(for: FoodClassifier().model)
            
//            self.model = model
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getPhotoItemAsImage(item: PhotosPickerItem) {
        Task {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                    print("Imagem selecionada com sucesso.")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func classify(uiImage: UIImage) {
        guard let cgImage = uiImage.cgImage else {
            print("Error: Image nil")
            return
        }
        
        guard let model else { return }
        
        //VNDetectFaceRectanglesRequest - Rostos
        //VNRecognizeTextRequest - OCR, Caracteres
        //VNCoreMLRequest - CoreML
        let request = VNCoreMLRequest(model: model) { [weak self] req, err in
            guard let results = req.results as? [VNClassificationObservation], //all the results as VNClassificationObservation
                  let top = results.first else { return } //Higher probability in the request
            
            
            DispatchQueue.main.async {
                let identifier1: String = top.identifier //o nome do identificador
                let identifier2: String = results[1].identifier
                let identifier3: String = results[2].identifier
                
                let confidence1: Float = top.confidence //esse cara é VNConfidence, mas é um typealias para Float
                let confidence2: Float = results[1].confidence //esse cara é VNConfidence, mas é um typealias para Float
                let confidence3: Float = results[2].confidence //esse cara é VNConfidence, mas é um typealias para Float
                
                self?.resultText = """
                    \(identifier1) (\(Int(confidence1 * 100))%)\n
                    \(identifier2) (\(Int(confidence2 * 100))%)\n
                    \(identifier3) (\(Int(confidence3 * 100))%)
                """
                
                print("Imagem processada pelo CoreML")
                print("\(identifier1) (\(Int(confidence1 * 100))%)")
                print("\(identifier2) (\(Int(confidence2 * 100))%)")
                print("\(identifier3) (\(Int(confidence3 * 100))%)")
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: uiImage.cgImageOrientation) //encapsula a imagem em um handler para a request
        
        do {
            try handler.perform([request])
        } catch {
            print("Request error: \(error.localizedDescription)")
        }
    }
}
