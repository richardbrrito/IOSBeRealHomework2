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
    @State private var userLastPostDate: Date? = nil
    @State private var isLoading = true
    @State private var commentInputs: [String: String] = [:] // For comment input per post

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

                // Posts List or Prompt
                if isLoading {
                    ProgressView().padding()
                } else if userLastPostDate == nil || userLastPostDate! < Date().addingTimeInterval(-24*60*60) {
                    Text("You must upload a post to see others' photos!")
                        .foregroundColor(.white)
                        .font(.title2)
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(posts) { post in
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(post.username)
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                    // Time and Location under username
                                    HStack(spacing: 10) {
                                        if let postTime = post.postTime {
                                            Text(DateFormatter.localizedString(from: postTime, dateStyle: .medium, timeStyle: .short))
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        if let location = post.location, !location.isEmpty {
                                            Text(location)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }

                                    Text(post.caption)
                                        .foregroundStyle(.white)

                                    if let imageData = post.imageData,
                                       let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .cornerRadius(12)
                                    }

                                    // Comments Section
                                    if let comments = post.comments, !comments.isEmpty {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Comments:")
                                                .font(.subheadline)
                                                .foregroundColor(.white)
                                            ForEach(comments, id: \.self) { comment in
                                                HStack(alignment: .top) {
                                                    Text(comment.username + ":")
                                                        .bold()
                                                        .foregroundColor(.blue)
                                                    Text(comment.content)
                                                        .foregroundColor(.white)
                                                }
                                            }
                                        }
                                        .padding(.top, 4)
                                    }

                                    // Add Comment Section
                                    HStack {
                                        TextField("Add a comment...", text: Binding(
                                            get: { commentInputs[post.objectId ?? ""] ?? "" },
                                            set: { commentInputs[post.objectId ?? ""] = $0 }
                                        ))
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(minHeight: 30)

                                        Button(action: {
                                            addComment(to: post)
                                        }) {
                                            Text("Send")
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.blue)
                                                .cornerRadius(8)
                                        }
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
                }

                Spacer()
            }
            .onAppear { fetchUserLastPostAndPosts() }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .modifier(BackgroundColorStyle())
            // Modern Navigation for MakePostView
            .navigationDestination(isPresented: $showMakePost) {
                MakePostView { newPost in
                    // After posting, refresh eligibility and posts
                    fetchUserLastPostAndPosts()
                }
            }
        }
    }

    private func fetchUserLastPostAndPosts() {
        isLoading = true
        guard let username = User.current?.username else {
            print("No current user or username");
            isLoading = false;
            posts = [];
            userLastPostDate = nil;
            return
        }
        // Fetch user's most recent post
        ParsePost.query("username" == username)
            .order([.descending("createdAt")])
            .limit(1)
            .find { result in
                switch result {
                case .success(let userPosts):
                    let lastPostDate = userPosts.first?.createdAt
                    print("User last post date: \(String(describing: lastPostDate))")
                    DispatchQueue.main.async {
                        self.userLastPostDate = lastPostDate
                    }
                    if let lastPostDate = lastPostDate {
                        if lastPostDate >= Date().addingTimeInterval(-24*60*60) {
                            // User has posted in last 24 hours, fetch others' posts
                            print("User eligible to see posts")
                            fetchRecentPosts(userLastPostDate: lastPostDate)
                        } else {
                            // User's last post is too old
                            print("User's last post is older than 24h, clearing posts")
                            DispatchQueue.main.async {
                                self.posts = []
                                self.isLoading = false
                            }
                        }
                    } else {
                        // User has never posted
                        print("User has never posted, clearing posts")
                        DispatchQueue.main.async {
                            self.posts = []
                            self.isLoading = false
                        }
                    }
                case .failure(let error):
                    print("Failed to fetch user posts: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.userLastPostDate = nil
                        self.posts = []
                        self.isLoading = false
                    }
                }
            }
    }

    private func fetchRecentPosts(userLastPostDate: Date) {
        let sinceDate = Date().addingTimeInterval(-24*60*60)
        let userCreatedAt = User.current?.createdAt
        ParsePost.query("createdAt" >= sinceDate)
            .order([.descending("createdAt")])
            .limit(10)
            .find { result in
                switch result {
                case .success(let fetchedPosts):
                    // Only show posts created within 24h AFTER user's last post and after user account creation
                    let filtered = fetchedPosts.filter { post in
                        if let created = post.createdAt, let userCreatedAt = userCreatedAt {
                            return created >= userLastPostDate &&
                                   created <= userLastPostDate.addingTimeInterval(24*60*60) &&
                                   created >= userCreatedAt
                        }
                        return false
                    }
                    DispatchQueue.main.async {
                        self.posts = filtered
                        self.isLoading = false
                    }
                case .failure(_):
                    DispatchQueue.main.async {
                        self.posts = []
                        self.isLoading = false
                    }
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

    private func addComment(to post: ParsePost) {
        guard let objectId = post.objectId, let username = User.current?.username else { return }
        let commentText = commentInputs[objectId]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !commentText.isEmpty else { return }
        var updatedPost = post
        var comments = updatedPost.comments ?? []
        comments.append(Comment(username: username, content: commentText))
        updatedPost.comments = comments
        updatedPost.save { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    commentInputs[objectId] = ""
                    fetchUserLastPostAndPosts()
                }
            case .failure(let error):
                print("Failed to add comment: \(error.localizedDescription)")
            }
        }
    }
}
