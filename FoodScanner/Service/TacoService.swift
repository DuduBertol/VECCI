//
//  TacoStore.swift
//  FoodScanner
//
//  Created by Eduardo Bertol on 08/10/25.
//

import Foundation
import Combine

struct TacoItem: Identifiable, Codable {
    let id: UUID
    let nome: String
    let energiaKcal: Double
    let proteina: Double
    let carboidratos: Double
    let lipideos: Double
    let fibras: Double
    
    init(
        id: UUID = UUID(),
        nome: String,
        energiaKcal: Double,
        proteina: Double,
        carboidratos: Double,
        lipideos: Double,
        fibras: Double
    ) {
        self.id = id
        self.nome = nome
        self.energiaKcal = energiaKcal
        self.proteina = proteina
        self.carboidratos = carboidratos
        self.lipideos = lipideos
        self.fibras = fibras
    }
    
    /// Calcula nutrientes proporcionais ao peso
    func calculateProportions(weight: Double) -> TacoItem {
        let factor = weight / 100.0
        
        return TacoItem(
            id: self.id,
            nome: self.nome,
            energiaKcal: self.energiaKcal * factor,
            proteina: self.proteina * factor,
            carboidratos: self.carboidratos * factor,
            lipideos: self.lipideos * factor,
            fibras: self.fibras * factor
        )
    }
}


final class TacoService: ObservableObject {
    @Published var items: [TacoItem] = []
    @Published var isLoading = false
    @Published var error: String?
    
    init() {
        loadTacoCSV(named: "TabelaTACO-filtered") // o arquivo taco.csv deve estar no bundle
    }
    
    func loadTacoCSV(named fileName: String) {
        isLoading = true
        error = nil
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            defer {
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
            }
            
            guard let url = Bundle.main.url(forResource: fileName, withExtension: "csv") else {
                DispatchQueue.main.async {
                    self?.error = "Arquivo TACO não encontrado"
                }
                return
            }
            
            do {
                let content = try String(contentsOf: url, encoding: .utf8)
                let lines = content.components(separatedBy: .newlines)
                
                var loadedItems: [TacoItem] = []
                
                for line in lines.dropFirst() { // pula o header
                    let trimmedLine = line.trimmingCharacters(in: .whitespaces)
                    if trimmedLine.isEmpty { continue }
                    
                    let columns = line.components(separatedBy: ";")
                    
                    // Esperado: descrição, energia, proteína, carboidrato, lipídeos, fibra
                    if columns.count >= 6 {
                        let nome = columns[0].trimmingCharacters(in: .whitespaces)
                        let energiaStr = columns[1].trimmingCharacters(in: .whitespaces)
                        let proteinaStr = columns[2].trimmingCharacters(in: .whitespaces)
                        let carboidratoStr = columns[3].trimmingCharacters(in: .whitespaces)
                        let lipideosStr = columns[4].trimmingCharacters(in: .whitespaces)
                        let fibraStr = columns[5].trimmingCharacters(in: .whitespaces)
                        
                        // Converter valores, tratando NA e notação científica
                        let energia = self?.parseDouble(energiaStr) ?? 0
                        let proteina = self?.parseDouble(proteinaStr) ?? 0
                        let carboidrato = self?.parseDouble(carboidratoStr) ?? 0
                        let lipideos = self?.parseDouble(lipideosStr) ?? 0
                        let fibra = self?.parseDouble(fibraStr) ?? 0
                        
                        let item = TacoItem(
                            nome: nome,
                            energiaKcal: energia,
                            proteina: proteina,
                            carboidratos: carboidrato,
                            lipideos: lipideos,
                            fibras: fibra
                        )
                        loadedItems.append(item)
                    }
                }
                
                DispatchQueue.main.async {
                    self?.items = loadedItems
                    print("✅ Carregados \(loadedItems.count) itens da TACO")
                }
                
            } catch {
                DispatchQueue.main.async {
                    self?.error = "Erro ao ler arquivo TACO: \(error.localizedDescription)"
                    print("❌ Erro ao ler TACO: \(error)")
                }
            }
        }
    }
    
    // MARK: - Search
    
    /// Busca exata
    func findExact(_ text: String) -> TacoItem? {
        let normalized = text.lowercased().trimmingCharacters(in: .whitespaces)
        return items.first { $0.nome.lowercased() == normalized }
    }
    
    /// Busca aproximada com Levenshtein distance (retorna o MELHOR match)
    func findClosest(_ text: String, threshold: Double = 0.6) -> TacoItem? {
        let normalized = text.lowercased().trimmingCharacters(in: .whitespaces)
        
        let scored = items.map { item in
            (item, levenshteinSimilarity(normalized, item.nome.lowercased()))
        }
            .filter { $0.1 >= threshold }
            .sorted { $0.1 > $1.1 }
        
        return scored.first?.0
    }
    
    /// Busca por palavra-chave (retorna o primeiro match)
    func searchByKeyword(_ keyword: String) -> TacoItem? {
        let normalized = keyword.lowercased().trimmingCharacters(in: .whitespaces)
        
        return items.first { item in
            item.nome.lowercased().contains(normalized)
        }
    }
    
    /// Busca inteligente: tenta exata, depois fuzzy, depois keyword
    func smartSearch(_ text: String) -> TacoItem? {
        // 1. Tenta busca exata
        if let exact = findExact(text) {
            return exact
        }
        
        // 2. Tenta busca fuzzy
        if let fuzzy = findClosest(text, threshold: 0.6) {
            return fuzzy
        }
        
        // 3. Tenta busca por palavra-chave
        return searchByKeyword(text)
    }
    
    func findAllMatches(_ text: String) -> [TacoItem] {
        let normalized = text.lowercased().trimmingCharacters(in: .whitespaces)
        
        let scored = items.map { item in
            (item, levenshteinSimilarity(normalized, item.nome.lowercased()))
        }
            .filter { $0.1 >= 0.5 }
            .sorted { $0.1 > $1.1 }
        
        return scored.map { $0.0 }
    }
    
    // MARK: - Similarity Metrics
    
    /// Levenshtein distance - mais preciso que count de caracteres comuns
    private func levenshteinSimilarity(_ a: String, _ b: String) -> Double {
        let distance = levenshteinDistance(a, b)
        let maxLength = max(a.count, b.count)
        
        guard maxLength > 0 else { return 1.0 }
        return 1.0 - (Double(distance) / Double(maxLength))
    }
    
    private func levenshteinDistance(_ a: String, _ b: String) -> Int {
        let a = Array(a)
        let b = Array(b)
        
        var matrix = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
        
        for i in 0...a.count {
            matrix[i][0] = i
        }
        
        for j in 0...b.count {
            matrix[0][j] = j
        }
        
        for i in 1...a.count {
            for j in 1...b.count {
                let cost = a[i - 1] == b[j - 1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i - 1][j] + 1,      // deletion
                    matrix[i][j - 1] + 1,      // insertion
                    matrix[i - 1][j - 1] + cost // substitution
                )
            }
        }
        
        return matrix[a.count][b.count]
    }
    
    private func parseDouble(_ value: String) -> Double {
        let cleaned = value.trimmingCharacters(in: .whitespaces)
        
        // Tratar NA como 0
        if cleaned.uppercased() == "NA" {
            return 0
        }
        
        // Tratar notação científica (ex: 1E-05 = 0.00001)
        if let double = Double(cleaned) {
            // Se é um valor muito pequeno (< 0.001), considerar como 0
            if double < 0.001 {
                return 0
            }
            return double
        }
        
        return 0
    }
}

