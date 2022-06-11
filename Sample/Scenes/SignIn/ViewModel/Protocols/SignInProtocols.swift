//
//  SignInProtocols.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 10/31/20.
//  Copyright © 2020 Serhii Krotkykh. All rights reserved.
//

import Foundation
import RxSwift

typealias SignInViewModel = SignInInOutputObserver & SignInInput

protocol SignInInOutputObserver {
    func signInOutputObserver(_ completion: @escaping (Result<Void, LVError>) -> Void)
}

protocol SignInInput {
    func signIn()
}

typealias SignInSupportable = SignInObservable & SignInConfiguarble & SignInLaunched

protocol SignInConfiguarble {
    var configurator: SignInConfigurator { set get }
    var presenter: UIViewController { get set }
}

protocol SignInObservable {
    var rxSignInResult: PublishSubject<Result<Void, LVError>> { get }
}

protocol SignInLaunched {
    func signIn()
}
