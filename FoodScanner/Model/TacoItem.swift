//
//  TacoItem.swift
//  FoodScanner
//
//  Created by Eduardo Bertol on 12/10/25.
//

import Foundation

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
