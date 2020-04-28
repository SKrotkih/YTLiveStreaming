//
//  GoogleSignInDependencies.swift
//  YouTubeLiveVideo
//

import UIKit
import YTLiveStreaming

class GoogleSignInDependencies: NSObject {
    
    func configure(_ viewController: GoogleSignInViewController) {
        let signInInteractor = AppDelegate.shared.googleSignIn

        viewController.viewModel = GoogleSignInViewModel(viewController: viewController, interactor: signInInteractor)
        viewController.viewModel.configure()

        viewController.interactor = signInInteractor
    }
}

