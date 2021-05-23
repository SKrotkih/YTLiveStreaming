//
//  SignInProtocol.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 10/31/20.
//  Copyright © 2020 Serhii Krotkykh. All rights reserved.
//

import Foundation
import RxSwift

protocol SignInProtocol {
    func startListeningToSignIn(_ completion: @escaping (Result<Void, LVError>) -> Void)
}

protocol SignInObservable {
    var rxSignInResult: PublishSubject<Result<Void, LVError>> { get }
    func configure()
}
