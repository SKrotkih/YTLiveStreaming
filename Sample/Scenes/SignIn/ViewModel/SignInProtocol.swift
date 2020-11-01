//
//  SignInProtocol.swift
//  YouTubeLiveVideo
//
//  Created by Sergey Krotkih on 10/31/20.
//  Copyright © 2020 Sergey Krotkih. All rights reserved.
//

import Foundation

protocol SignInProtocol {
    func configureSignIn(for viewController: UIViewController)
    func startListeningToSignIn(_ completion: @escaping (Result<Void, LVError>) -> Void)
}
