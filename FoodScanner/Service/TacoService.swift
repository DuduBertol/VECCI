//
//  TacoStore.swift
//  FoodScanner
//
//  Created by Eduardo Bertol on 08/10/25.
//

import Foundation
import Combine

struct TacoItem: Identifiable, Codable {
    let id = UUID()
    
    let nome: String
    let energiaKcal: Double
    let proteina: Double
    let lipideos: Double
    let carboidratos: Double
}

extension TacoItem {
    static func mockEmpty() -> TacoItem {
        TacoItem(nome: "None", energiaKcal: 0, proteina: 0, lipideos: 0, carboidratos: 0)
    }
}

final class TacoService: ObservableObject {
    @Published var items: [TacoItem] = []
    
    init() {
        loadTacoCSV(named: "TabelaTACO-Completa") // o arquivo taco.csv deve estar no bundle
    }
    
    func loadTacoCSV(named fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "csv") else { return }
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)
            
            for line in lines.dropFirst() { // pula o header
                let columns = line.components(separatedBy: ",")
                if columns.count >= 9 {
                    let item = TacoItem(
                        nome: columns[2],
                        energiaKcal: Double(columns[5]) ?? 0,
                        proteina: Double(columns[7]) ?? 0,
                        lipideos: Double(columns[8]) ?? 0,
                        carboidratos: Double(columns[10]) ?? 0
                    )
                    items.append(item)
                }
            }
        } catch {
            print("Erro ao ler TACO: \(error)")
        }
    }
    
    /// Busca exata
    func findExact(_ text: String) -> TacoItem? {
        items.first { $0.nome.lowercased() == text.lowercased() }
    }
    
    /// Busca aproximada (fuzzy)
    func findClosest(_ text: String) -> TacoItem? {
        let normalized = text.lowercased()
        let sorted = items.map { item in
            (item, similarityScore(between: normalized, and: item.nome.lowercased()))
        }
        .sorted { $0.1 > $1.1 }
        return sorted.first?.0
    }
    
    /// Simples métrica de similaridade (quanto maior, melhor)
    private func similarityScore(between a: String, and b: String) -> Int {
        let common = Set(a).intersection(Set(b))
        return common.count
    }
}

