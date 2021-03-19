//
//  LiveEventsPublisher.swift
//  LiveEvents
//
//  Created by Сергей Кротких on 27.10.2020.
//  Copyright © 2020 Sergey Krotkih. All rights reserved.
//

import Foundation
import RxSwift

protocol YouTubeLiveVideoPublisher: class {
    func willStartPublishing(completed: @escaping (String?, NSDate?) -> Void)
    func finishPublishing()
    func didUserCancelPublishingVideo()
    var rxDidUserFinishWatchVideo: PublishSubject<Bool> { get }
    var rxStateDescription: PublishSubject<String> { get }
    var rxError: PublishSubject<String> { get }
}
