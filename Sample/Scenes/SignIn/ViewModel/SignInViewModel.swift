//
//  SignInViewModel.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import RxSwift

class GoogleSignInViewModel: SignInViewModel {
    @Lateinit var interactor: SignInSupportable

    private let disposeBag = DisposeBag()

    required init(interactor: SignInSupportable) {
        self.interactor = interactor
    }

    func signIn() {
        interactor.signIn()
    }

    func signInOutputObserver(_ completion: @escaping (Result<Void, LVError>) -> Void) {
        interactor
            .rxSignInResult
            .subscribe(onNext: { result in
                completion(result)
            }).disposed(by: disposeBag)
    }
}
