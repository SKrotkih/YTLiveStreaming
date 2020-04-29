//
//  GoogleSignInViewController.swift
//  YouTubeLiveVideo
//

import UIKit
import GoogleSignIn

// [START viewcontroller_interfaces]
class GoogleSignInViewController: BaseViewController {
    // [END viewcontroller_interfaces]
    
    var viewModel: GoogleSignInViewModel!
    var interactor: GoogleSignInInteractor!
    
    // [START viewcontroller_vars]
    @IBOutlet weak var signInButton: GIDSignInButton!
    // [END viewcontroller_vars]
    
    let dependencies = GoogleSignInDependencies()
    
    // [START viewdidload]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dependencies.configure(self)
        startListeningToSignIn()
        viewModel.configure()
    }
    // [END viewdidload]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
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
                    switch error {
                        case .systemMessage(let code, let message):
                            if code == 401 {
                                print(message)
                            } else {
                                Alert.sharedInstance.showOk("", message: message)
                        }
                        case .message(let message):
                            Alert.sharedInstance.showOk("", message: message)
                }
            }
        }
    }
}
