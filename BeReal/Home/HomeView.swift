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

    var body: some View {
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
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.white)

                
                Spacer()
                
                Button(action: {
                    logout()
                }) {
                    Text("Logout")
                        .foregroundColor(.blue)
                        .padding(.trailing)
                        .foregroundStyle(.white)

                }
            }
            .padding()
            .background(Color.white.opacity(0.2))
            
            // Make Post Button
            Button(action: {
                print("📝 Make Post tapped")
                // Add your create post logic here
            }) {
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .modifier(BackgroundColorStyle())
    }
    
    private func logout() {
        User.logout { result in
            switch result {
            case .success:
                print("✅ Logged out successfully")
                DispatchQueue.main.async {
                    isLoggedIn = false
                }
            case .failure(let error):
                print("❌ Logout failed: \(error.localizedDescription)")
            }
        }
    }
}
