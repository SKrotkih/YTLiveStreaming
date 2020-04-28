//
//  GoogleSignInView.swift
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

class GoogleSignInView: GoogleSignInViewInterface {
    
    unowned let viewController: StreamListViewController
    
    private let disposeBag = DisposeBag()
    
   var signinInteractor: GoogleSignInInteractor!
    
    init(viewController: StreamListViewController) {
        self.viewController = viewController
    }
    
    func didLoad() {

        viewController.signOutButton.rx
            .tap
            .subscribe(onNext: { [weak self]  _ in
                guard let `self` = self else { return }
                self.signinInteractor.signOut()
                self.presentUserInfo()
            }).disposed(by: disposeBag)

        signinInteractor.rxSignOut
        .subscribe(onNext: { [weak self] accessToken in
            GoogleOAuth2.sharedInstance.clearToken()
        }).disposed(by: disposeBag)
        
        
    }
    
    private func presentUserInfo() {
       if let userInfo = signinInteractor.currentUserInfo {
          viewController.presentUserInfo(connected: true, userInfo: userInfo)
          loadData()
       } else {
          viewController.presentUserInfo(connected: false, userInfo: "")
       }
    }

    func reloadData() {
       guard signinInteractor.isConnected else {
          return
       }
//       interactor.reloadData() { upcoming, current, past  in
//          self.viewController.present(content: (upcoming, current, past))
//       }
    }
    
    fileprivate func loadData() {
       guard signinInteractor.isConnected else {
          return
       }
//       interactor.loadData() { (upcoming, current, past) in
//          self.viewController.present(content: (upcoming, current, past))
//       }
    }

    
    
}

