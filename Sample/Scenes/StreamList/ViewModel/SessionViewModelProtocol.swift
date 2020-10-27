//
//  SessionViewModelProtocol.swift
//  YouTubeLiveVideo
//
//  Created by Сергей Кротких on 27.10.2020.
//  Copyright © 2020 Sergey Krotkih. All rights reserved.
//

import Foundation
import RxSwift

protocol SessionViewModel {
    var rxSignOut: PublishSubject<Bool> { get }
    func signOut()
}
