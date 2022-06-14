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
                self.parse(result)
            }).disposed(by: disposeBag)
    }

    private func parse(_ result: Result<Void, LVError>) {
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
