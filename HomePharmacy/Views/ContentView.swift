import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var databaseItems: [Medication]
    
    @State private var viewModel = MedicineViewModel()
    @State private var isAddSheetPresented = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Форма", selection: $viewModel.selectedFormFilter) {
                    Text("Все").tag("Все")
                    Text("Таблетки").tag("Таблетки")
                    Text("Сиропы").tag("Сироп")
                }
                .pickerStyle(.segmented)
                .padding()
                
                List {
                    ForEach(viewModel.medications) { medication in
                        NavigationLink(value: medication) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(medication.name)
                                        .font(.headline)
                                    Text("Вещество: \(medication.activeSubstance)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(medication.form)
                                        .font(.caption).bold()
                                        .padding(.horizontal, 6).padding(.vertical, 2)
                                        .background(Color.blue.opacity(0.1)).cornerRadius(4)
                                    
                                    Text("Срок: \(medication.expirationDate, style: .date)")
                                        .font(.caption2)
                                        .foregroundColor(medication.expirationDate < Date() ? .red : .gray)
                                }
                            }
                        }
                    }
                    .onDelete(perform: removeMedication)
                }
            }
            .navigationTitle("Моя Аптечка (Вариант 11)")
            .navigationDestination(for: Medication.self) { item in
                MedicationDetailView(medication: item)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { isAddSheetPresented = true }) {
                        Image(systemName: "plus.circle.fill").font(.title3)
                    }
                }
            }
            .sheet(isPresented: $isAddSheetPresented) {
                AddMedicationSheet(viewModel: viewModel)
            }
            .onAppear { viewModel.syncAndFilter(databaseItems) }
            .onChange(of: databaseItems) { _, newValue in viewModel.syncAndFilter(newValue) }
            .onChange(of: viewModel.selectedFormFilter) { _, _ in viewModel.syncAndFilter(databaseItems) }
        }
    }
    
    private func removeMedication(at offsets: IndexSet) {
        for index in offsets {
            let item = viewModel.medications[index]
            modelContext.delete(item)
        }
        try? modelContext.save()
    }
}
