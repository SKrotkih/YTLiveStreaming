//
//  MainViewModelProtocol.swift
//  YouTubeLiveVideo
//
//  Created by Сергей Кротких on 27.10.2020.
//  Copyright © 2020 Sergey Krotkih. All rights reserved.
//

import Foundation
import RxSwift

protocol MainViewModelOutput {
    func didOpenViewAction()
    func didCloseViewAction()
    func didSignOutAction()
    func didCreateBroadcastAction()
    func didLaunchStreamAction(indexPath: IndexPath, viewController: UIViewController)
}

protocol MainViewModelInput {
    var rxSignOut: PublishSubject<Bool> { get }
    var rxError: PublishSubject<String> { get }
    var rxData: PublishSubject<[SectionModel]> { get }
}

protocol SignInInteractor {
    // Input
    var rxSignOut: PublishSubject<Bool> { get }
    // Output
    func signOut()
}

extension GoogleSignInInteractor: SignInInteractor {
}
