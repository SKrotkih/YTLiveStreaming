//
//  GoogleSignInViewModel.swift
//  YouTubeLiveVideo
//

import Foundation
import YTLiveStreaming
import GoogleSignIn
import RxSwift

class GoogleSignInViewModel {
    private let interactor = AppDelegate.shared.googleSignIn
    unowned let viewController: UIViewController
    private let disposeBag = DisposeBag()
    
    init(viewController: UIViewController) {
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
