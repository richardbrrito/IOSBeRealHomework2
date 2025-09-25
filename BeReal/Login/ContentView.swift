//
//  ContentView.swift
//  BeReal
//
//  Created by Richard Brito on 9/23/25.
//

import SwiftUI
import ParseSwift

struct ContentView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            if isLoggedIn {
                HomeView(isLoggedIn: $isLoggedIn)
            } else {
                VStack(spacing: 20) {
                    Text("BeReal.")
                        .font(.system(size: 60))
                        .foregroundStyle(.white)
                    
                    // Username field
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color(.gray))
                        .cornerRadius(10)
                        .autocapitalization(.none)
                    
                    // Password field
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.gray))
                        .cornerRadius(10)
                    
                    // Login button
                    Button(action: {
                        login()
                    }) {
                        Text("Login")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    // Sign Up button
                    NavigationLink(destination: SignUpView(isLoggedIn: $isLoggedIn)) {
                        Text("Sign Up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    // Show error if login fails
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.top, 10)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .modifier(BackgroundColorStyle())
            }
        }
    }
    
    private func login() {
        User.login(username: username, password: password) { result in
            switch result {
            case .success(let user):
                print("✅ Logged in: \(user)")
                DispatchQueue.main.async {
                    isLoggedIn = true
                }
            case .failure(let error):
                print("❌ Login failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
