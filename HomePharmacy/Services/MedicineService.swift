import Foundation
import Combine

final class MedicineService {
    private let mockApiUrl = URL(string: "https://mock-pharmacy-registry.com")
    
    func fetchMedicationDetails(by name: String) -> AnyPublisher<NetworkMedicationInfo, Error> {
        guard let url = mockApiUrl else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: NetworkMedicationInfo.self, decoder: JSONDecoder())
            .catch { _ in
                Just(NetworkMedicationInfo(
                    name: name,
                    activeSubstance: name == "Аспирин" ? "Аспирин" : "Ибупрофен",
                    defaultInstructions: "Принимать строго после еды, запивая большим количеством воды.",
                    standardDosage: "500 мг"
                ))
                .setFailureType(to: Error.self)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
