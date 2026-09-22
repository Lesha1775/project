import Foundation
import SwiftData

@Model
final class Medication {
    @Attribute(.unique) var id: UUID
    var name: String               // Коммерческое название
    var activeSubstance: String    // Действующее вещество
    var form: String               // Форма выпуска (Таблетки, Сироп)
    var dosage: String             // Дозировка
    var remainder: Double          // Остаток
    var expirationDate: Date       // Срок годности
    var usageInstructions: String  // Инструкция
    
    init(id: UUID = UUID(), name: String, activeSubstance: String, form: String, dosage: String, remainder: Double, expirationDate: Date, usageInstructions: String) {
        self.id = id
        self.name = name
        self.activeSubstance = activeSubstance
        self.form = form
        self.dosage = dosage
        self.remainder = remainder
        self.expirationDate = expirationDate
        self.usageInstructions = usageInstructions
    }
}

struct IncompatibilityRule: Codable, Identifiable {
    let id: String
    let substanceA: String
    let substanceB: String
    let dangerDescription: String
}

struct NetworkMedicationInfo: Codable {
    let name: String
    let activeSubstance: String
    let defaultInstructions: String
    let standardDosage: String
}
