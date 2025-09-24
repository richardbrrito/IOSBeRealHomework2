import SwiftUI
import PhotosUI
import ParseSwift

struct MakePostView: View {
    @Environment(\.dismiss) var dismiss
    @State private var caption: String = ""
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var selectedUIImage: UIImage? = nil

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

            Spacer()

            // Post Button
            Button(action: {
                guard let username = User.current?.username else { return }

                let post = ParsePost(username: username, caption: caption, image: selectedUIImage)

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
