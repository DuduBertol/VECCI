//
//  FoundationModelsService.swift
//  FoodScanner
//
//  Created by Eduardo Bertol on 08/10/25.
//

import Foundation
import FoundationModels
import SwiftUI

class FoundationModelService {
    
    private var session: LanguageModelSession?
    private let model = SystemLanguageModel.default
    
    init() {
        
        setupSession()
    }
    
    func setupSession() {
        let instructions = """
        Você é um especialista em nutrição e análise de alimentos brasileiros.
        Sua função é analisar imagens de refeições e identificar:
        1. Todos os ingredientes/alimentos visíveis
        2. Estimativa de peso de cada item em gramas
        
        Forneça respostas em formato JSON estruturado.
        Use nomes de alimentos compatíveis com a Tabela TACO brasileira.
        Os nomes devem estar em Português brasileiro.
        Os nomes devem conter apenas uma ou duas palavras.
        Seja conservador nas estimativas de peso, estimando para menos.
        """
        
        session = LanguageModelSession(instructions: instructions)
        
    }
    
    func quitSession() {
        session = nil
    }
    
    func analyzeFood(_ name: String) async throws -> FoodAnalysis {
     
        //eu poderia receber uma imagem que vira um texto dps, por analise
        let prompt = createAnalysisPrompt(foodName: name)
        
        guard let session = session else {
            throw AnalysisError.sessionNotInitialized
        }
        
        guard case .available = model.availability else {
            throw AnalysisError.modelUnavailable
        }
        
        let response = try await session.respond(to: prompt)
        
        // 4. Parse da resposta JSON
        let analysis = try parseAnalysisResponse(response.content)
        
        return analysis
    }
    
    private func parseAnalysisResponse(_ response: String) throws -> FoodAnalysis {
        
        //Limpar a resposta
        var jsonString = response
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Se o JSON está envolvido em aspas, remover
        if jsonString.hasPrefix("\"") && jsonString.hasSuffix("\"") {
            jsonString = String(jsonString.dropFirst().dropLast())
        }
        
        // Tentar extrair JSON se houver texto extra
        if let startIndex = jsonString.firstIndex(of: "{"),
           let endIndex = jsonString.lastIndex(of: "}") {
            jsonString = String(jsonString[startIndex...endIndex])
        }
        
        print("🔍 Resposta limpa: \(jsonString)")
        
        guard let data = jsonString.data(using: .utf8) else {
            throw AnalysisError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        
        do {
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
            
        } catch let decodingError as NSError {
            print("❌ Erro ao decodificar JSON: \(decodingError)")
            print("❌ Resposta original: \(response)")
            throw AnalysisError.invalidResponse
        }
        
//        let parsed = try decoder.decode(AnalysisResponse.self, from: data)
//        
//        var ingredients: [String] = []
//        var weights: [String: Double] = [:]
//        
//        for item in parsed.ingredients {
//            ingredients.append(item.nome)
//            weights[item.nome] = item.peso_gramas
//        }
//        
//        
//        return FoodAnalysis(
//            ingredients: ingredients,
//            estimatedWeight: weights,
//            confidence: parsed.confidence
//            
//        )
        
    }
    
    private func createAnalysisPrompt(foodName: String) -> String {
            """
            Analise esta descrição de alimento: \(foodName)
            
            Retorne APENAS um JSON válido neste formato exato, sem texto adicional:
            {
                "ingredients": [
                    {
                        "nome": "suposto ingrediente",
                        "peso_gramas": 150
                    },
                    {
                        "nome": "outro suposto ingrediente",
                        "peso_gramas": 100
                    }
                ],
                "confidence": 0.85
            }
            
            IMPORTANTE:
            - Array deve se chamar "ingredients" (em inglês)
            - Cada item deve ter "nome" em português e "peso_gramas"
            - Preencha esses campos com os ingredientes, peso e confiança identificados
            - Não inclua "preparacao" no JSON
            - confidence deve estar entre 0 e 1
            - NÃO adicione NENHUM texto fora do JSON
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
