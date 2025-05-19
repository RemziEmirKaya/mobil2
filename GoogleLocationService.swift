import Foundation
import CoreLocation

class GoogleLocationService {
    private let apiKey = "AIzaSyBBbDVYmOpDp9NbYzCiARyT6MAU4qZdQLA" // Kendi API anahtarınızı buraya yazın.

    func fetchLocationFromIP(completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        guard let url = URL(string: "https://www.googleapis.com/geolocation/v1/geolocate?key=\(apiKey)") else {
            print("❌ URL geçersiz")
            completion(nil)
            return
        }

        // Wi-Fi ve IP adresine dayalı konum almak için kullanılacak JSON veri yapısı
        let requestData = [
            "wifiAccessPoints": [
                [
                    "macAddress": "01:23:45:67:89:AB",  // Wi-Fi Access Point MAC adresi (örnek)
                    "signalStrength": -65,             // Sinyal gücü
                    "signalToNoiseRatio": 40           // Sinyal gürültü oranı
                ]
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestData, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Ağ Hatası: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let location = json["location"] as? [String: Double],
                  let lat = location["lat"],
                  let lng = location["lng"] else {
                print("❌ JSON ayrıştırılamadı")
                completion(nil)
                return
            }

            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            completion(coordinate)
        }.resume()
    }
}
