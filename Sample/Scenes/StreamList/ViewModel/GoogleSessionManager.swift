//
//  GoogleSessionManager.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih
//

import UIKit
import RxSwift

class GoogleSessionManager: SessionManager {
    
    var interactor: SignInInteractor!
    let rxSignOut = PublishSubject<Bool>()
    
    private let disposeBag = DisposeBag()
    
    init(_ interactor: GoogleSignInInteractor) {
        self.interactor = interactor
        bindEvents()
    }
    
    func signOut() {
        self.interactor.signOut()
    }

    private func bindEvents() {
        interactor
            .rxSignOut
            .subscribe(onNext: { [weak self] _ in
                self?.rxSignOut.onNext(true)
            }).disposed(by: disposeBag)
    }
}
