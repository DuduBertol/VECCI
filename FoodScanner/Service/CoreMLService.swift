//
//  CoreMLService.swift
//  FoodScanner
//
//  Created by Eduardo Bertol on 08/10/25.
//

import Foundation
import CoreML
import Vision
import UIKit

enum MLModelAvailableType {
    case foodClassifier, vecci
}

class CoreMLService {
    
    private var model: VNCoreMLModel?
    
    init() {
        setupMLModel()
    }
    
    func setupMLModel(to model: MLModelAvailableType = .vecci) {
        do {
            switch model {
            case .foodClassifier:
                self.model = try VNCoreMLModel(for: FoodClassifier().model)
            case .vecci:
                self.model = try VNCoreMLModel(for: VECCI().model)
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func classify(_ uiImage: UIImage) throws -> [Food] {
        
        var tempResults: [Food] = []
        
        guard let cgImage = uiImage.cgImage else {
            print("Error: Image nil")
            return []
        }
        
        guard let model else { return [] } //isso nao seria o ideal
        
        //VNDetectFaceRectanglesRequest - Rostos
        //VNRecognizeTextRequest - OCR, Caracteres
        //VNCoreMLRequest - CoreML
        let request = VNCoreMLRequest(model: model) { req, err in
            guard let results = req.results as? [VNClassificationObservation] //all the results as VNClassificationObservation
//                  let top = results.first
            else { return } //Higher probability in the request
            
            
            let identifier1: String = results[0].identifier
            let identifier2: String = results[1].identifier
            let identifier3: String = results[2].identifier

            let confidence1: Float = results[0].confidence
            let confidence2: Float = results[1].confidence
            let confidence3: Float = results[2].confidence
            
            print("Imagem processada pelo CoreML")
            print("\(identifier1) (\(Int(confidence1 * 100))%)")
            print("\(identifier2) (\(Int(confidence2 * 100))%)")
            print("\(identifier3) (\(Int(confidence3 * 100))%)")
            
            tempResults = [
                Food(identifier: identifier1, confidence: confidence1),
//                Food(identifier: identifier2, confidence: confidence2),
//                Food(identifier: identifier3, confidence: confidence3),
            ]
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: uiImage.cgImageOrientation) //encapsula a imagem em um handler para a request
        
        try handler.perform([request])
        
        return tempResults
        
    }
}

struct Food: Identifiable, Codable {
    let id: UUID
    var identifier: String
//    let formattedName: String?
    var confidence: Float
    
    init(
        identifier: String,
        confidence: Float
    ){
        self.id = UUID()
        self.identifier = identifier
//        self.formattedName = nil
        self.confidence = confidence
    }
    
    func getName() -> String {
        identifier
    }
}
