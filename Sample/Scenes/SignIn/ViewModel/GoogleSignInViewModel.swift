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
    var interactor: SignInObservable!
    private let disposeBag = DisposeBag()
    
    required init(viewController: UIViewController, interactor: GoogleSignInInteractor) {
        GIDSignIn.sharedInstance()?.presentingViewController = viewController
        self.interactor = interactor
        self.interactor.configure()
    }
    
    func startListeningToSignIn(_ completion: @escaping (Result<Void, LVError>) -> Void) {
        interactor
            .rxSignInResult
            .subscribe(onNext: { result in
                completion(result)
            }).disposed(by: disposeBag)
    }
}
