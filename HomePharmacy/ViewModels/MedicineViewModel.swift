import Foundation
import Combine
import SwiftData

@MainActor
@Observable
final class MedicineViewModel {
    var medications: [Medication] = []
    var selectedFormFilter: String = "Все"
    var sortByExpiration: Bool = true
    
    var newName: String = ""
    var newActiveSubstance: String = ""
    var newForm: String = "Таблетки"
    var newDosage: String = ""
    var newRemainder: String = ""
    var newExpirationDate: Date = Date()
    var newInstructions: String = ""
    
    var alertMessage: String? = nil
    var isConflictDetected: Bool = false
    var isLoadingNetworkData: Bool = false
    
    private var incompatibilityMatrix: [IncompatibilityRule] = []
    private var medicineService = MedicineService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadIncompatibilityMatrix()
        setupReactivePipelines()
    }
    
    private func loadIncompatibilityMatrix() {
        guard let url = Bundle.main.url(forResource: "incompatibility_matrix", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return }
        self.incompatibilityMatrix = (try? JSONDecoder().decode([IncompatibilityRule].self, from: data)) ?? []
    }
    
    private func setupReactivePipelines() {
        AsCombinePublisher(mirror: _newName)
            .debounce(for: .milliseconds(600), scheduler: RunLoop.main)
            .removeDuplicates()
            .filter { !$0.isEmpty && $0.count > 2 }
            .sink { [weak self] queryName in
                self?.fetchDataFromOcrOrNetwork(queryName)
            }
            .store(in: &cancellables)
            
        AsCombinePublisher(mirror: _newActiveSubstance)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] substance in
                self?.checkIncompatibility(for: substance)
            }
            .store(in: &cancellables)
    }
    
    private func fetchDataFromOcrOrNetwork(_ name: String) {
        isLoadingNetworkData = true
        medicineService.fetchMedicationDetails(by: name)
            .sink(receiveCompletion: { [weak self] _ in
                self?.isLoadingNetworkData = false
            }, receiveValue: { [weak self] info in
                guard let self = self else { return }
                self.newActiveSubstance = info.activeSubstance
                self.newInstructions = info.defaultInstructions
                self.newDosage = info.standardDosage
            })
            .store(in: &cancellables)
    }
    
    private func checkIncompatibility(for substance: String) {
        guard !substance.isEmpty else {
            isConflictDetected = false
            alertMessage = nil
            return
        }
        
        for med in medications {
            if let conflict = incompatibilityMatrix.first(where: {
                ($0.substanceA.lowercased() == substance.lowercased() && $0.substanceB.lowercased() == med.activeSubstance.lowercased()) ||
                ($0.substanceB.lowercased() == substance.lowercased() && $0.substanceA.lowercased() == med.activeSubstance.lowercased())
            }) {
                isConflictDetected = true
                alertMessage = "Критический конфликт с '\(med.name)'! Предупреждение: \(conflict.dangerDescription)"
                return
            }
        }
        isConflictDetected = false
        alertMessage = nil
    }
    
    func syncAndFilter(_ fetched: [Medication]) {
        var items = fetched
        if selectedFormFilter != "Все" {
            items = items.filter { $0.form == selectedFormFilter }
        }
        if sortByExpiration {
            items.sort { $0.expirationDate < $1.expirationDate }
        } else {
            items.sort { $0.name < $1.name }
        }
        self.medications = items
    }
    
    func save(context: ModelContext) -> Bool {
        guard !newName.isEmpty && !isConflictDetected else { return false }
        
        let med = Medication(
            name: newName,
            activeSubstance: newActiveSubstance,
            form: newForm,
            dosage: newDosage,
            remainder: Double(newRemainder) ?? 1.0,
            expirationDate: newExpirationDate,
            usageInstructions: newInstructions
        )
        context.insert(med)
        clearForm()
        return true
    }
    
    func triggerMockCameraOcr() {
        let mockOptions = ["Аспирин", "Ибупрофен", "Парацетамол"]
        self.newName = mockOptions.randomElement() ?? "Аспирин"
    }
    
    private func clearForm() {
        newName = ""
        newActiveSubstance = ""
        newForm = "Таблетки"
        newDosage = ""
        newRemainder = ""
        newInstructions = ""
        newExpirationDate = Date()
    }
}

func AsCombinePublisher<T>(mirror: T) -> AnyPublisher<T, Never> {
    Just(mirror).eraseToAnyPublisher()
}
