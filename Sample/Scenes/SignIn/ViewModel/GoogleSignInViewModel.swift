//
//  GoogleSignInViewModel.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih
//

import Foundation
import GoogleSignIn
import RxSwift

class GoogleSignInViewModel: SignInProtocol {
    private let interactor = AppDelegate.shared.googleSignIn
    private let disposeBag = DisposeBag()
    
    func configureSignIn(for viewController: UIViewController) {
        GIDSignIn.sharedInstance()?.presentingViewController = viewController
        interactor.configure()
    }
    
    func startListeningToSignIn(_ completion: @escaping (Result<Void, LVError>) -> Void) {
        interactor
            .rxSignInResult
            .subscribe(onNext: { result in
                completion(result)
            }).disposed(by: disposeBag)
    }
}
