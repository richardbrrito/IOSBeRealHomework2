//
//  SignUpView.swift
//  BeReal
//
//  Created by Richard Brito on 9/23/25.
//

import SwiftUI


import SwiftUI
import ParseSwift

struct SignUpView: View {
    @Binding var isLoggedIn: Bool
    @State private var username = ""
    @State private var password = ""
    @State private var email = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("BeReal.")
                .font(.system(size: 60))
                .foregroundStyle(.white)

            TextField("Username", text: $username)
                .padding()
                .background(Color(.gray))
                .cornerRadius(10)
                .autocapitalization(.none)

            TextField("Email", text: $email)
                .padding()
                .background(Color(.gray))
                .cornerRadius(10)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .padding()
                .background(Color(.gray))
                .cornerRadius(10)

            Button("Sign Up") {
                signUp()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.2))
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .modifier(BackgroundColorStyle())
    }

    private func signUp() {
        var newUser = User()
        newUser.username = username
        newUser.email = email
        newUser.password = password

        newUser.signup { result in
            switch result {
            case .success(let user):
                print("✅ Signed up: \(user)")
                DispatchQueue.main.async {
                    isLoggedIn = true
                }
            case .failure(let error):
                print("❌ Error: \(error.localizedDescription)")
            }
        }
    }
}
