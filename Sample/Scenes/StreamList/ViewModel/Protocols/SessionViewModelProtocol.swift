//
//  SessionViewModelProtocol.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 27.10.2020.
//  Copyright © 2020 Serhii Krotkykh. All rights reserved.
//

import Foundation
import RxSwift

protocol SessionManager {
    /// Observable data lets know that the user is signed in
    ///
    /// - Parameters:
    ///
    /// - Returns:
    var rxSignOut: PublishSubject<Bool> { get }
    /// The user wants to sign out
    ///
    /// - Parameters:
    ///
    /// - Returns:
    func signOut()
}
