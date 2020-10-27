//
//  GoogleSessionViewModel.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih
//

import UIKit
import RxSwift

class GoogleSessionViewModel: SessionViewModel {
    
    var interactor: GoogleSignInInteractor!
    let rxSignOut: PublishSubject<Bool> = PublishSubject()
    
    private let disposeBag = DisposeBag()
    
    init(_ interactor: GoogleSignInInteractor) {
        self.interactor = interactor
        bindEvents()
    }
    
    private func bindEvents() {
        interactor
            .rxSignOut
            .subscribe(onNext: { [weak self] _ in
                self?.rxSignOut.onNext(true)
            }).disposed(by: disposeBag)
    }
    
    func signOut() {
        self.interactor.signOut()
    }
}
