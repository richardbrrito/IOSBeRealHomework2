//
//  HomeView.swift
//  BeReal
//
//  Created by Richard Brito on 9/23/25.
//

import SwiftUI
import ParseSwift

struct HomeView: View {
    @Binding var isLoggedIn: Bool
    @State private var posts: [ParsePost] = []
    @State private var showMakePost = false

    var body: some View {
        NavigationStack {
            VStack {
                // Top Bar
                HStack {
                    Image(systemName: "person.2.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.leading)
                        .foregroundStyle(.white)

                    Spacer()

                    Text("BeReal")
                        .font(.system(size: 30))
                        .foregroundStyle(.white)

                    Spacer()

                    Button(action: logout) {
                        Text("Logout")
                            .font(.system(size: 20))
                            .padding(.trailing)
                            .foregroundStyle(.white)
                    }
                }
                .padding()

                //Make Post Button
                Button(action: { showMakePost = true }) {
                    Text("Make Post")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .padding(.top, 10)

                // Posts List
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(posts) { post in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(post.username)
                                    .font(.headline)
                                    .foregroundStyle(.white)

                                Text(post.caption)
                                    .foregroundStyle(.white)

                                if let imageData = post.imageData,
                                   let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(12)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }

                Spacer()
            }
            .onAppear { fetchPosts() }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .modifier(BackgroundColorStyle())
            // Modern Navigation for MakePostView
            .navigationDestination(isPresented: $showMakePost) {
                MakePostView { newPost in
                    posts.insert(newPost, at: 0)
                }
            }
        }
    }

    private func fetchPosts() {
        ParsePost.query()
            .order([.descending("createdAt")])
            .find { result in
                switch result {
                case .success(let fetchedPosts):
                    DispatchQueue.main.async { posts = fetchedPosts }
                case .failure(let error):
                    print("❌ Failed to fetch posts: \(error.localizedDescription)")
                }
            }
    }

    private func logout() {
        User.logout { result in
            switch result {
            case .success:
                DispatchQueue.main.async { isLoggedIn = false }
            case .failure(let error):
                print("❌ Logout failed: \(error.localizedDescription)")
            }
        }
    }
}
