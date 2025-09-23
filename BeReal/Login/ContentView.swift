//
//  ContentView.swift
//  BeReal
//
//  Created by Richard Brito on 9/23/25.
//

import SwiftUI

struct ContentView: View {
    @State private var username = ""
    @State private var password = ""

    var body: some View {
        NavigationStack{
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
                    // Handle login
                }) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                // Sign Up button
                NavigationLink(destination: SignUpView()) {
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .modifier(BackgroundColorStyle())
        }
    }
}

#Preview {
    ContentView()
}
