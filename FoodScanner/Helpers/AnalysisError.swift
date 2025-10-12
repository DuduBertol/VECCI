//
//  AnalysisError.swift
//  FoodScanner
//
//  Created by Eduardo Bertol on 12/10/25.
//

import Foundation

enum AnalysisError: LocalizedError {
    case modelUnavailable
    case sessionNotInitialized
    case invalidResponse
    case imageProcessingFailed
    
    var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            return "Foundation Models não está disponível neste dispositivo"
        case .sessionNotInitialized:
            return "Sessão não inicializada"
        case .invalidResponse:
            return "Resposta do modelo inválida"
        case .imageProcessingFailed:
            return "Falha ao processar imagem"
        }
    }
}
