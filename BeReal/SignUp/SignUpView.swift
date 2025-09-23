//
//  SignUpView.swift
//  BeReal
//
//  Created by Richard Brito on 9/23/25.
//

import SwiftUI


struct SignUpView: View {
        @State private var username = ""
        @State private var password = ""
        @State private var email = ""
       var body: some View {
           VStack(spacing:20){
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

               // Password field
               SecureField("Password", text: $password)
                   .padding()
                   .background(Color(.gray))
                   .cornerRadius(10)
           }.padding()
               .frame(maxWidth: .infinity, maxHeight: .infinity)
               .modifier(BackgroundColorStyle())
       }
   }
