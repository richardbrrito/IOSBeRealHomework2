import SwiftUI
import PhotosUI
import ParseSwift
import CoreLocation

// Location Manager to handle location updates
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var locationString: String? = nil

    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied || status == .restricted {
            DispatchQueue.main.async {
                self.locationString = "Location unavailable"
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                if let placemark = placemarks?.first {
                    if let city = placemark.locality, let state = placemark.administrativeArea {
                        self.locationString = "\(city), \(state)"
                    } else {
                        self.locationString = String(format: "%.4f, %.4f", location.coordinate.latitude, location.coordinate.longitude)
                    }
                } else {
                    self.locationString = String(format: "%.4f, %.4f", location.coordinate.latitude, location.coordinate.longitude)
                }
            }
        }
        manager.stopUpdatingLocation()
    }
}

struct MakePostView: View {
    @Environment(\.dismiss) var dismiss
    @State private var caption: String = ""
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var selectedUIImage: UIImage? = nil
    @StateObject private var locationManager = LocationManager()

    var onPost: ((ParsePost) -> Void)? // Callback to update HomeView feed

    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("Create a Post")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(.white)

            // Caption input
            TextField("Write a caption...", text: $caption)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
                .foregroundColor(.white)
                .padding(.horizontal)

            // Image Picker
            PhotosPicker(selection: $selectedImage, matching: .images) {
                HStack {
                    Image(systemName: "photo")
                    Text("Select an Image")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .onChange(of: selectedImage) { newItem in
                Task {
                    guard let data = try? await newItem?.loadTransferable(type: Data.self),
                          let uiImage = UIImage(data: data)
                    else { return }
                    selectedUIImage = uiImage
                }
            }

            // Preview Selected Image
            if let uiImage = selectedUIImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 250)
                    .cornerRadius(12)
                    .padding()
            }

            // Display Location
            if let location = locationManager.locationString {
                Text("Location: \(location)")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                Text("Getting location...")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            // Post Button
            Button(action: {
                guard let username = User.current?.username else { return }

                let post = ParsePost(
                    username: username,
                    caption: caption,
                    image: selectedUIImage,
                    location: locationManager.locationString,
                    postTime: Date()
                )

                // Save to Parse
                post.save { result in
                    switch result {
                    case .success(let savedPost):
                        print("✅ Post saved: \(savedPost)")
                        DispatchQueue.main.async {
                            onPost?(savedPost) // Update HomeView feed
                            dismiss()           // Close MakePostView
                        }
                    case .failure(let error):
                        print("❌ Failed to save post: \(error.localizedDescription)")
                    }
                }
            }) {
                Text("Post")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
        }
        .padding(.top)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .modifier(BackgroundColorStyle())
    }
}
