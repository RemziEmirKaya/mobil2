import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var generateQRButton: UIButton!

    let locationManager = CLLocationManager() // Konum yöneticisi

    override func viewDidLoad() {
        super.viewDidLoad()

        // Konum yöneticisini ayarlıyoruz
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

        // Konum izni talebi
        locationManager.requestWhenInUseAuthorization()

        // Konum güncellemelerini başlatıyoruz
        locationManager.startUpdatingLocation()
        
        // Arka plan rengi
        view.backgroundColor = UIColor.systemTeal

        // Buton stili
        generateQRButton.layer.cornerRadius = 10
        generateQRButton.backgroundColor = UIColor.systemBlue
        generateQRButton.tintColor = .white
        generateQRButton.layer.shadowColor = UIColor.black.cgColor
        generateQRButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        generateQRButton.layer.shadowOpacity = 0.1
        generateQRButton.layer.shadowRadius = 5

        // QR kod görüntüsünü yuvarla
        qrCodeImageView.layer.cornerRadius = 15
        qrCodeImageView.layer.masksToBounds = true
    }

    // Konum güncellemeleri geldiğinde çağrılacak fonksiyon
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Son güncellenen konumu al
        if let newLocation = locations.last {
            print("Mevcut Konum: \(newLocation.coordinate.latitude), \(newLocation.coordinate.longitude)")
        }
    }

    // Konum güncelleme hatası durumunda çağrılır
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showAlert(title: "Konum Hatası", message: "Konum alınamadı: \(error.localizedDescription)")
    }

    // QR kodu oluşturulacaksa butona tıklanınca çalışacak
    @IBAction func generateQRCodeButtonTapped(_ sender: UIButton) {
        if let currentLocation = locationManager.location {
            generateQRCodeForCurrentLocation(from: currentLocation)
        } else {
            showAlert(title: "Hata", message: "Mevcut konum alınamadı.")
        }
    }

    // Mevcut konumu kullanarak QR kodu oluştur
    func generateQRCodeForCurrentLocation(from location: CLLocation) {
        let locationString = "https://www.google.com/maps?q=\(location.coordinate.latitude),\(location.coordinate.longitude)"
        
        if let qrCodeImage = createQRCode(from: locationString) {
            qrCodeImageView.image = qrCodeImage
        } else {
            showAlert(title: "Hata", message: "QR kod oluşturulamadı.")
        }
    }

    // QR kod görselini üret
    func createQRCode(from string: String) -> UIImage? {
        guard let data = string.data(using: .utf8) else { return nil }
        
        // CIFilter kullanarak QR kodu üretmek için qrCodeGenerator filtresini kullanıyoruz
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("Q", forKey: "inputCorrectionLevel") // Hata düzeltme seviyesini belirliyoruz (Q: 25% hata düzeltmesi)
            
            if let outputImage = filter.outputImage {
                // Görseli belirli bir boyuta ölçeklendirme
                let scaleX = qrCodeImageView.frame.size.width / outputImage.extent.size.width
                let scaleY = qrCodeImageView.frame.size.height / outputImage.extent.size.height
                let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
                return UIImage(ciImage: transformedImage)
            }
        }
        return nil
    }

    // Hata alert'i göster
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
