//
//  SignInBodyView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import SwiftUI
import GoogleSignInSwift

/// SwiftUI content view for the Google Sign In
struct SignInBodyView: View {
    var viewModel: SignInViewModel

    var body: some View {
        VStack {
            Spacer()
            Image("icon-logo")
                .resizable()
                .scaledToFit()
            Spacer()
            GoogleSignInButton(scheme: .dark, style: .standard, action: {
                viewModel.signIn()
            })
            .padding()
            .frame(width: 100.0)

            Spacer()
        }
        .padding(.top, 80.0)
        .padding(.bottom, 80.0)
    }
}

struct SignInBodyView_Previews: PreviewProvider {
    static var previews: some View {
        let interactor = GoogleSignInInteractor()
        let viewModel = GoogleSignInViewModel(interactor: interactor)
        SignInBodyView(viewModel: viewModel)
    }
}
