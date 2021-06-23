//
//  LiveEventsPublisher.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 27.10.2020.
//  Copyright © 2020 Serhii Krotkykh. All rights reserved.
//

import Foundation
import RxSwift

protocol YouTubeLiveVideoPublisher: AnyObject {
    func willStartPublishing(completed: @escaping (String?, NSDate?) -> Void)
    func finishPublishing()
    func didUserCancelPublishingVideo()
    var rxDidUserFinishWatchVideo: PublishSubject<Bool> { get }
    var rxStateDescription: PublishSubject<String> { get }
    var rxError: PublishSubject<String> { get }
}
