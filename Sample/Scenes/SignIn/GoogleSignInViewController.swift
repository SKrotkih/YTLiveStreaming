//
//  GoogleSignInViewController.swift
//  YouTubeLiveVideo
//

import UIKit
import GoogleSignIn

// [START viewcontroller_interfaces]
class GoogleSignInViewController: UIViewController {
    // [END viewcontroller_interfaces]

    var viewModel: GoogleSignInViewModel!
    var interactor: GoogleSignInInteractor!
    
    // [START viewcontroller_vars]
    @IBOutlet weak var signInButton: GIDSignInButton!
    // [END viewcontroller_vars]
    
    let dependencies = GoogleSignInDependencies()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    // [START viewdidload]
    override func viewDidLoad() {
        super.viewDidLoad()
        dependencies.configure(self)
    }
    // [END viewdidload]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startListeningToSignIn()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let streamListVC = segue.destination as? StreamListViewController {
            streamListVC.signInInteractor = interactor
        }
    }
}

// MARK: - Private Methods

extension GoogleSignInViewController {
    
    private func startListeningToSignIn() {
        viewModel.startListeningToSignIn { result in
            switch result {
            case .success():
                DispatchQueue.performUIUpdate {
                    self.performSegue(withIdentifier: "streamlist", sender: nil)
                }
            case .failure(let error):
                Alert.sharedInstance.showOk("", message: error.message())
            }
        }
    }
}
