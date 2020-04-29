//
//  GoogleSessionViewModel.swift
//  YouTubeLiveVideo
//

import UIKit
import YTLiveStreaming
import RxCocoa
import RxSwift

protocol GoogleSignInViewInterface {
    func didLoad()
    func reloadData()
}

class GoogleSessionViewModel {
    
    unowned let viewController: StreamListViewController
    unowned let interactor: GoogleSignInInteractor
    
    private let disposeBag = DisposeBag()
    
    init(viewController: StreamListViewController, signInInteractor: GoogleSignInInteractor) {
        self.viewController = viewController
        self.interactor = signInInteractor
    }
    
    func bindEvents() {
        
        viewController.navigationItem.leftBarButtonItem?.rx
        .tap
        .debounce(.milliseconds(Constants.UI.debounce), scheduler: MainScheduler.instance)
        .subscribe(onNext: { [weak self]  _ in
            guard let `self` = self else { return }
            self.interactor.signOut()
            self.viewController.close()
        }).disposed(by: disposeBag)

        interactor
            .rxSignOut
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.viewController.stopActivity()
                self.viewController.close()
            }).disposed(by: disposeBag)
    }
}
