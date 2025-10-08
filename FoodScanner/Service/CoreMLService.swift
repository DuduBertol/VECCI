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

class CoreMLService {
    
    private var model: VNCoreMLModel?
    
    var results: [VNClassificationObservation] = []
    
    init() {
        setupMLModel()
    }
    
    private func setupMLModel() {
        do {
//            let model = try VNCoreMLModel(for: FoodClassifier().model)
            self.model = try VNCoreMLModel(for: FoodClassifier().model)
            
//            self.model = model
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func classify(_ uiImage: UIImage) throws -> [String: Float] {
        
        guard let cgImage = uiImage.cgImage else {
            print("Error: Image nil")
            return [:]
        }
        
        guard let model else { return [:] } //isso nao seria o ideal
        
        //VNDetectFaceRectanglesRequest - Rostos
        //VNRecognizeTextRequest - OCR, Caracteres
        //VNCoreMLRequest - CoreML
        let request = VNCoreMLRequest(model: model) { [weak self] req, err in
            guard let results = req.results as? [VNClassificationObservation], //all the results as VNClassificationObservation
                  let top = results.first else { return } //Higher probability in the request
            
            self?.results = results
            print(results)
            
//            DispatchQueue.main.async {
//                let identifier1: String = top.identifier //o nome do identificador
//                let identifier2: String = results[1].identifier
//                let identifier3: String = results[2].identifier
//                
//                let confidence1: Float = top.confidence //esse cara é VNConfidence, mas é um typealias para Float
//                let confidence2: Float = results[1].confidence //esse cara é VNConfidence, mas é um typealias para Float
//                let confidence3: Float = results[2].confidence //esse cara é VNConfidence, mas é um typealias para Float
//                
//                self?.resultText = """
//                    \(identifier1) (\(Int(confidence1 * 100))%)\n
//                    \(identifier2) (\(Int(confidence2 * 100))%)\n
//                    \(identifier3) (\(Int(confidence3 * 100))%)
//                """
//                
//                print("Imagem processada pelo CoreML")
//                print("\(identifier1) (\(Int(confidence1 * 100))%)")
//                print("\(identifier2) (\(Int(confidence2 * 100))%)")
//                print("\(identifier3) (\(Int(confidence3 * 100))%)")
//            }
        }
        
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
        
        
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: uiImage.cgImageOrientation) //encapsula a imagem em um handler para a request
        
        try handler.perform([request])
        
        
        return [
            identifier1 : confidence1,
            identifier2 : confidence2,
            identifier3 : confidence3
        ]
        
    }
}
