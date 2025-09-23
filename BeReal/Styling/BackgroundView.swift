//
//  BackgroundView.swift
//  BeReal
//
//  Created by Richard Brito on 9/23/25.
//

import SwiftUI

struct BackgroundColorStyle: ViewModifier {

    func body(content: Content) -> some View {
        return content
            .background(Color.black)
    }
}


extension View {
    func backgroundStyle() -> some View {
        self.modifier(BackgroundColorStyle())
    }
}
