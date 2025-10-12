//
//  InfoSheet.swift
//  FoodScanner
//
//  Created by Eduardo Bertol on 12/10/25.
//

import SwiftUI

struct InfoSheet: View {
    
    @Binding var food: FinalFoodAnalysed
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading, spacing: 32){
                VStack{
                    HStack{
                        Spacer()
                        Text("VECCI")
                            .font(.title)
                            .bold()
                        Spacer()
                    }
                    .padding(.top, 32)
                }
                
                VStack{
                    Text("""
                        **VECCI** - Vision Estimation and Classification for Calories and Ingredients
                        
                        VECCI possui um modelo que foi treinado com base em **120k fotos**, com uma precisão de **75%** em classificar **175 classes** de comida.
                        Visto sua limitação de precisão na identificação de alimentos, considera-se sua principal finalidade o **estudo** sobre Machine Learning, uso dos frameworks CoreML, CreateML, Vision e FoundationModels.
                        
                        Seus dados podem não condizer com a realidade! 
                    """)
                        .font(.caption)
                        .foregroundStyle(.opacity(0.75))
                }
//                    .padding(.horizontal, 16)
                
                VStack{
                    Text("""
                    Passos realizados:
                    
                        **1)** Análise da foto pelo **MLModel** 
                        **2)** Tradução do nome da classe e estimativa de ingredientes pelo **FoundationModel**. 
                        **3)** Cálculo de Proporcionalidade pela Tabela **TACO**.
                    """)
                    .padding(32)
                    .background(.opacity(0.075))
                    .cornerRadius(16)
                }

                VStack(alignment: .leading){
                    if $food.modelName.wrappedValue != "None" {
                        Text("Informações sobre seu alimento:")
                            .font(.callout)
                            .foregroundStyle(.opacity(0.5))
                            .padding(.bottom, 16)
                        
                        TextStatsRowView(title: "Nome da Classe", content: $food.modelName.wrappedValue)
                        TextStatsRowView(title: "Nome Traduzido", content: $food.translatedName.wrappedValue)
                            .padding(.bottom, 16)

                        NumberStatsRowView(title: "Confiança", amount: Double($food.confidence.wrappedValue * 100), unit: "%")
                            .padding(.bottom, 16)
                        
                        ForEach($food.ingredients.wrappedValue.indices, id: \.self) { i in
                            TextStatsRowView(title: "Ingrediente: \(i + 1)", content: $food.ingredients[i].wrappedValue)
                        }
                        .padding(.bottom, 16)
                        
                        NumberStatsRowView(title: "Calorias", amount: $food.calories_kcal.wrappedValue, unit: "Kcal")
                        NumberStatsRowView(title: "Proteínas", amount: $food.proteins_g.wrappedValue)
                        NumberStatsRowView(title: "Carboidratos", amount: $food.carbohydrates_g.wrappedValue)
                        NumberStatsRowView(title: "Gorduras", amount: $food.fats_g.wrappedValue)
                        NumberStatsRowView(title: "Fibras", amount: $food.fibers_g.wrappedValue)
                    } else {
                        Text("Insira uma foto para analisar...")
                            .font(.callout)
                            .foregroundStyle(.opacity(0.5))
                    }
                }
                
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    InfoSheet(food: .constant(FinalFoodAnalysed(
            modelName: "None",
            translatedName: "None",
            confidence: 0,
            ingredients: ["None", "None"],
            totalWeight_g: 0,
            calories_kcal: 0,
            proteins_g: 0,
            carbohydrates_g: 0,
            fats_g: 0,
            fibers_g: 0
        )
    ))
}

//                Text("Classe: \($food.modelName.wrappedValue)")
//                Text("Nome Traduzido: \($food.translatedName.wrappedValue)")
//                Text("Confiança: \($food.confidence.wrappedValue)")
//                Text("Ingredientes: \($food.ingredients.wrappedValue)")
//                Text("Peso Total (g): \($food.totalWeight_g.wrappedValue)")
//                Text("Calorias (kcal): \($food.calories_kcal.wrappedValue)")
//                Text("Proteínas (g): \($food.proteins_g.wrappedValue)")
//                Text("Carboidratos (g): \($food.carbohydrates_g.wrappedValue)")
//                Text("Gorduras (g): \($food.fats_g.wrappedValue)")
//                Text("Fibras (g): \($food.fibers_g.wrappedValue)")
