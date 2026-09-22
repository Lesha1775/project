import SwiftUI

struct AddMedicationSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: MedicineViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Автоматизация сканирования") {
                    Button(action: { viewModel.triggerMockCameraOcr() }) {
                        HStack {
                            Image(systemName: "camera.viewfinder")
                            Text("Имитировать сканирование упаковки (OCR)")
                        }
                        .foregroundColor(.orange)
                    }
                    if viewModel.isLoadingNetworkData {
                        HStack {
                            ProgressView()
                            Text("Запрос спецификаций из REST API...").font(.caption).foregroundColor(.gray)
                        }
                    }
                }
                
                Section("Ввод данных") {
                    TextField("Коммерческое название", text: $viewModel.newName)
                    TextField("Действующее вещество", text: $viewModel.newActiveSubstance)
                    
                    Picker("Форма выпуска", selection: $viewModel.newForm) {
                        Text("Таблетки").tag("Таблетки")
                        Text("Сироп").tag("Сироп")
                        Text("Капли").tag("Капли")
                    }
                    
                    TextField("Дозировка (например, 500мг)", text: $viewModel.newDosage)
                    TextField("Количество", text: $viewModel.newRemainder).keyboardType(.decimalPad)
                    DatePicker("Срок годности", selection: $viewModel.newExpirationDate, displayedComponents: .date)
                }
                
                Section("Инструкция по применению") {
                    TextEditor(text: $viewModel.newInstructions).frame(minHeight: 60)
                }
                
                if viewModel.isConflictDetected, let errorMsg = viewModel.alertMessage {
                    Section {
                        HStack {
                            Image(systemName: "exclamationmark.shield.fill").foregroundColor(.red)
                            Text(errorMsg).font(.footnote).foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Новое лекарство")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Добавить") {
                        if viewModel.save(context: modelContext) { dismiss() }
                    }
                    .disabled(viewModel.newName.isEmpty || viewModel.isConflictDetected)
                }
            }
        }
    }
}
