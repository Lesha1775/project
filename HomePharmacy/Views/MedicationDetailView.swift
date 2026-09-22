import SwiftUI

struct MedicationDetailView: View {
    let medication: Medication
    
    var body: some View {
        Form {
            Section("Детали препарата") {
                LabeledContent("Название", value: medication.name)
                LabeledContent("Компонент", value: medication.activeSubstance)
                LabeledContent("Форма выпуска", value: medication.form)
                LabeledContent("Дозировка", value: medication.dosage)
            }
            Section("Учет остатков и сроки") {
                LabeledContent("В наличии", value: "\(medication.remainder) ед.")
                LabeledContent("Годен до", value: medication.expirationDate.formatted(date: .long, time: .omitted))
            }
            Section("Текстовая инструкция") {
                Text(medication.usageInstructions)
                    .font(.body)
            }
        }
        .navigationTitle(medication.name)
    }
}
