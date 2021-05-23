//
//  NewStreamViewModel.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 24.03.2021.
//  Copyright © 2021 Serhii Krotkykh. All rights reserved.
//

import Foundation
import RxSwift
import YTLiveStreaming

protocol NewStreamProtocol {
    var title: String { get set }
    var description: String { get set }
    var hours: String { get set }
    var minutes: String { get set }
    var secunds: String { get set }
    var date: Date { get set }
    var verification: Result<Void, LVError> { get }
    func createBroadcast()
    var rxOperationCompleted: PublishSubject<Bool> { get }
    var rxStartDate: PublishSubject<String> { get }
}

class NewStreamViewModel: NewStreamProtocol {
    var broadcastsAPI: YTLiveStreaming!
    let rxOperationCompleted: PublishSubject<Bool> = PublishSubject()
    let rxStartDate: PublishSubject<String> = PublishSubject()

    private var model = NewStream(
        title: "",
        description: "",
        hours: "",
        minutes: "",
        seconds: "",
        date: Date()
    )

    var title: String {
        get { model.title }
        set { model.title = newValue }
    }

    var description: String {
        get { model.description }
        set { model.description = newValue }
    }

    var hours: String {
        get { model.hours }
        set { model.hours = newValue; upateUi() }
    }

    var minutes: String {
        get { model.minutes }
        set { model.minutes = newValue; upateUi() }
    }

    var secunds: String {
        get { model.seconds }
        set { model.seconds = newValue; upateUi() }
    }

    var date: Date {
        get { model.date }
        set { model.date = newValue; upateUi() }
    }

    var verification: Result<Void, LVError> { model.verification() }
}

// MARK: - Pesenter

extension NewStreamViewModel {
    private func upateUi() {
        rxStartDate.onNext(dateFormatted(date: model.startStreaming))
    }

    private func dateFormatted(date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd hh:mm:ss"
        return df.string(from: date)
    }
}

// MARK: - Interactor

extension NewStreamViewModel {

    func createBroadcast() {
        self.broadcastsAPI.createBroadcast(model.title,
                                           description: model.description,
                                           startTime: model.startStreaming,
                                           completion: { [weak self] result in
            switch result {
            case .success(let broadcast):
                Alert.showOk("Good job!", message: "You have scheduled a new broadcast with title '\(broadcast.snippet.title)'")
                self?.rxOperationCompleted.onNext(true)
            case .failure(let error):
                switch error {
                case .systemMessage(let code, let message):
                    let text = "\(code): \(message)"
                    Alert.showOk("Error", message: text)
                default:
                    Alert.showOk("Error", message: error.message())
                }
            }
        })
    }
}
