//
//  GoogleSessionManager.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import UIKit
import RxSwift

class GoogleSessionManager: SessionManager {
    var interactor: SignInInteractor!
    var rxSignOut: PublishSubject<Bool> {
        return interactor.rxSignOut
    }

    init(_ interactor: GoogleSignInInteractor) {
        self.interactor = interactor
    }

    func signOut() {
        interactor.signOut()
    }
}
