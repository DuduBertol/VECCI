//
//  FoundationModelsService.swift
//  FoodScanner
//
//  Created by Eduardo Bertol on 08/10/25.
//

import Foundation
import FoundationModels
import SwiftUI

class FoundationModelsService {
    
    private var session: LanguageModelSession?
    private let model = SystemLanguageModel.default
    
    let instructions = "Analise esse alimento e retorne possiveis ingredientes que vcoê diden"
    
    
    init() {
        
        let instructions = """
        Você é um especialista em nutrição e análise de alimentos brasileiros.
        Sua função é analisar imagens de refeições e identificar:
        1. Todos os ingredientes/alimentos visíveis
        2. Estimativa de peso de cada item em gramas
        3. Método de preparação (cru, cozido, frito, assado, etc)
        
        Forneça respostas em formato JSON estruturado.
        Use nomes de alimentos compatíveis com a Tabela TACO brasileira.
        Seja preciso mas conservador nas estimativas de peso.
        """
        
        session = LanguageModelSession(instructions: instructions)
    }
    
    func analyzeFood(_ name: String) async throws -> FoodAnalysis {
     
        //eu poderia receber uma imagem que vira um texto dps, por analise
        let prompt = createAnalysisPrompt(imageName: name)
        
        guard let session = session else {
            throw AnalysisError.sessionNotInitialized
        }
        
        let response = try await session.respond(to: prompt)
        
        // 4. Parse da resposta JSON
        let analysis = try parseAnalysisResponse(response.content)
        
        return analysis
    }
    
    private func parseAnalysisResponse(_ response: String) throws -> FoodAnalysis {
        
        let jsonString = response
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let data = jsonString.data(using: .utf8) else {
            throw AnalysisError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        let parsed = try decoder.decode(AnalysisResponse.self, from: data)
        
        var ingredients: [String] = []
        var weights: [String: Double] = [:]
        
        for item in parsed.ingredients {
            ingredients.append(item.nome)
            weights[item.nome] = item.peso_gramas
        }
        
        
        return FoodAnalysis(
            ingredients: ingredients,
            estimatedWeight: weights,
            confidence: parsed.confidence
            
        )
        
    }
    
    private func createAnalysisPrompt(imageName: String) -> String {
            """
            Analise esta refeição: \(imageName)
            
            Retorne APENAS um JSON válido neste formato exato:
            {
                "ingredientes": [
                    {
                        "nome": "arroz branco",
                        "peso_gramas": 150,
                        "preparacao": "cozido"
                    },
                    {
                        "nome": "feijão preto",
                        "peso_gramas": 100,
                        "preparacao": "cozido"
                    }
                ],
                "confianca": 0.85
            }
            
            Importante:
            - Use nomes da Tabela TACO (ex: "arroz, integral, cozido")
            - Pesos realistas para porção individual
            - Confiança entre 0 e 1
            - Não adicione texto extra, apenas o JSON
            """
        }
}

private struct AnalysisResponse: Codable {
    let ingredients: [Ingredient]
    let confidence: Double
    
    struct Ingredient: Codable {
        let nome: String
        let peso_gramas: Double
    }
}

struct FoodAnalysis {
    let ingredients: [String]
    let estimatedWeight: [String: Double] //g
    let confidence: Double
}


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
