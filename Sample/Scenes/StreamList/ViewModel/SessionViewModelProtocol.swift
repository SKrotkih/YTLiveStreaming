//
//  SessionViewModelProtocol.swift
//  LiveEvents
//
//  Created by Сергей Кротких on 27.10.2020.
//  Copyright © 2020 Sergey Krotkih. All rights reserved.
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
