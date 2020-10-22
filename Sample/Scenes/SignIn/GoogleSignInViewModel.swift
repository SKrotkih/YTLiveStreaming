//
//  GoogleSignInViewModel.swift
//  YouTubeLiveVideo
//

import Foundation
import YTLiveStreaming
import GoogleSignIn
import RxSwift

class GoogleSignInViewModel {
    unowned let interactor: GoogleSignInInteractor
    unowned let viewController: UIViewController
    private let disposeBag = DisposeBag()
    
    init(viewController: UIViewController, interactor: GoogleSignInInteractor) {
        self.interactor = interactor
        self.viewController = viewController
    }
    
    func configure() {
        GIDSignIn.sharedInstance()?.presentingViewController = self.viewController
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
