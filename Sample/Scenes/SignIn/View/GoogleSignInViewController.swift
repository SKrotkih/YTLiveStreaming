//
//  GoogleSignInViewController.swift
//  LiveEvents
//
//  Created by Sergey Krotkih
//

import UIKit
import GoogleSignIn

// [START viewcontroller_interfaces]
class GoogleSignInViewController: BaseViewController {
    // [END viewcontroller_interfaces]

    var viewModel: SignInProtocol!

    // [START viewcontroller_vars]
    @IBOutlet weak var signInButton: GIDSignInButton!
    // [END viewcontroller_vars]

    // [START viewdidload]
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        bindInput()
    }
    // [END viewdidload]

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

extension GoogleSignInViewController {
    private func bindInput() {
        viewModel
            .startListeningToSignIn { result in
            switch result {
            case .success:
                Router.showMainViewController()
            case .failure(let error):
                switch error {
                case .systemMessage(let code, let message):
                        if code == 401 {
                            print(message)
                        } else {
                            Alert.showOk("", message: message)
                        }
                case .message(let message):
                        Alert.showOk("", message: message)
                }
            }
        }
    }
}
