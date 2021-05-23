//
//  NewStreamViewController.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 24.03.2021.
//  Copyright © 2021 Serhii Krotkykh. All rights reserved.
//

import UIKit
import RxSwift

class NewStreamViewController: BaseViewController {

    var viewModel: NewStreamProtocol!

    @IBOutlet weak var titleTextFiled: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var afterHoursTextField: UITextField!
    @IBOutlet weak var afterMinutesTextField: UITextField!
    @IBOutlet weak var afterSecondsTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var runAtLabel: UILabel!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Schedule a new live video"
        configureRightBarButtonItem()
        configureOutput()
        bindInput()
    }

    private func configureRightBarButtonItem() {
        let doneButton = UIBarButtonItem.init(title: "Done",
                                              style: .plain,
                                              target: self,
                                              action: #selector(createNewBroadcast))
        self.navigationItem.rightBarButtonItem = doneButton
    }

    private func configureOutput() {
        titleTextFiled
            .rx
            .text
            .subscribe { [weak self] in
            self?.viewModel.title = $0 ?? ""
        }.disposed(by: disposeBag)
        descriptionTextField
            .rx
            .text
            .subscribe { [weak self] in
            self?.viewModel.description = $0 ?? ""
        }.disposed(by: disposeBag)
        afterHoursTextField
            .rx
            .text
            .subscribe { [weak self] in
            self?.viewModel.hours = $0 ?? ""
        }.disposed(by: disposeBag)
        afterMinutesTextField
            .rx
            .text
            .subscribe { [weak self] in
            self?.viewModel.minutes = $0 ?? ""
        }.disposed(by: disposeBag)
        afterSecondsTextField
            .rx
            .text
            .subscribe { [weak self] in
            self?.viewModel.secunds = $0 ?? ""
        }.disposed(by: disposeBag)
        datePicker
            .rx
            .date
            .asObservable()
            .subscribe { [weak self] in
                self?.viewModel.date = $0
            }.disposed(by: disposeBag)
    }

    @objc
    private func createNewBroadcast() {
        switch viewModel.verification {
        case .success:
            Alert.showConfirmCancel(
                "YouTube Live Streaming API",
                message: "Do you realy want to create a new Live broadcast video?",
                onConfirm: {
                    self.viewModel.createBroadcast()
                }
            )
        case .failure(let error):
            Alert.showOk("Error", message: error.message())
        }
    }

    private func bindInput() {
        viewModel
            .rxStartDate
            .subscribe(onNext: { [weak self] value in
                DispatchQueue.performUIUpdate { [weak self] in
                    self?.runAtLabel.text = value
                }
            }).disposed(by: disposeBag)
        viewModel
            .rxOperationCompleted
            .subscribe(onNext: { [weak self] _ in
                DispatchQueue.performUIUpdate { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
            }).disposed(by: disposeBag)
    }
}
