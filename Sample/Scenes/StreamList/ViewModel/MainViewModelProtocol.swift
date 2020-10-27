//
//  MainViewModelProtocol.swift
//  YouTubeLiveVideo
//
//  Created by Сергей Кротких on 27.10.2020.
//  Copyright © 2020 Sergey Krotkih. All rights reserved.
//

import Foundation
import RxSwift

protocol MainViewModel {
    var rxSignOut: PublishSubject<Bool> { get }
    var rxData: PublishSubject<[SectionModel]> { get }
    func loadData()
    func closeView()
    func signOut()
    func creadeBroadcast()
    func launchStream(indexPath: IndexPath, viewController: UIViewController)
}
