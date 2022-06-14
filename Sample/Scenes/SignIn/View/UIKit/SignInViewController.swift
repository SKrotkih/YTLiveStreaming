//
//  SignInViewController.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import UIKit
import GoogleSignIn

// [START viewcontroller_interfaces]
class SignInViewController: BaseViewController {
    // [END viewcontroller_interfaces]

    @Lateinit var viewModel: SignInViewModel

    // [START viewcontroller_vars]
    @IBOutlet weak var signInButton: GIDSignInButton!
    // [END viewcontroller_vars]

    // [START viewdidload]
    override func viewDidLoad() {
        super.viewDidLoad()

        customizeSignInButtonAppearance()
    }
    // [END viewdidload]

    @IBAction func signIn(_ sender: Any) {
        launchSignIn()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        showNavBar(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        showNavBar(false, animated: animated)
    }

    private func showNavBar(_ show: Bool, animated: Bool) {
        self.navigationController?.setNavigationBarHidden(show, animated: animated)
    }
}

// MARK: - Private Methods

extension SignInViewController {
    private func customizeSignInButtonAppearance() {
        signInButton.style = .standard
        signInButton.colorScheme = .dark
    }

    private func launchSignIn() {
        viewModel.signIn()
    }
}
