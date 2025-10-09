//
//  FoundationModelsService.swift
//  FoodScanner
//
//  Created by Eduardo Bertol on 08/10/25.
//

import Foundation
import FoundationModels
import SwiftUI

class FormatNameFMService {
    
    private var session: LanguageModelSession?
    private let model = SystemLanguageModel.default
    
    let instructions: String? = nil
    
    
    init() {
        
//        let instructions = """
//        Você é um especialista em nutrição e análise de alimentos brasileiros.
//        Sua função é analisar esse nome de alimento enviado para você e retorná-lo traduzido para Português PT-BR.
//        
//        Forneça respostas somente com o nome do alimento.
//        Não modifique nem insira novas informações além do nome enviado.
//        Seja preciso mas conservador na tradução.
//        """
        
        session = LanguageModelSession(instructions: instructions)
    }
    
    func formatName(_ name: String) async throws -> String {
        
//        let prompt = "Formate o nome desse alimento para português: \(name)"
        let prompt = "Traduza para português: \(name) e me retorne somente o nome do alimento:"
        
        guard let session = session else {
            throw AnalysisError.sessionNotInitialized
        }
        
        let response = try await session.respond(to: prompt)
        
        return response.content.description
    }
}
