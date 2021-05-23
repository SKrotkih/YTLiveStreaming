//
//  GoogleSignInViewModel.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import RxSwift

class GoogleSignInViewModel: SignInProtocol {
    var interactor: SignInObservable!
    private let disposeBag = DisposeBag()

    required init(interactor: GoogleSignInInteractor) {
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
