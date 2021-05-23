//  Alert.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import UIKit

let Alert = AlertController.sharedInstance

class AlertController: NSObject {
    struct Command {
        let title: String
        let message: String
        let actions: [String: () -> Void]
    }

    var popupWindow: UIWindow!
    var rootVC: UIViewController!

    class var sharedInstance: AlertController {
        struct SingletonWrapper {
            static let sharedInstance = AlertController()
        }
        return SingletonWrapper.sharedInstance
    }

    fileprivate override init() {
        let screenBounds = UIScreen.main.bounds
        popupWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: screenBounds.width, height: screenBounds.height))
        popupWindow.windowLevel = UIWindow.Level.statusBar + 1

        rootVC = StatusBarShowingViewController()
        popupWindow.rootViewController = rootVC

        super.init()
    }

    func showOk(_ title: String, message: String, onComplete: @escaping () -> Void = {  }) {
        popupWindow.isHidden = false
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
            self.popupWindow.isHidden = true
            onComplete()
        }))
        rootVC.present(alert, animated: true, completion: nil)
    }

    func showOkCancel(_ title: String,
                      message: String,
                      onComplete: @escaping () -> Void = {},
                      onCancel: @escaping () -> Void = {}) {
        let command = Command(title: title, message: message, actions: ["Ok": onComplete, "Close": onCancel])
        showAlert(command)
    }

    func showYesNo(_ title: String,
                   message: String,
                   onYes: @escaping () -> Void = {},
                   onNo: @escaping () -> Void = {}) {
        let command = Command(title: title, message: message, actions: ["Yes": onYes, "No": onNo])
        showAlert(command)
    }

    func showConfirmCancel(_ title: String,
                           message: String,
                           onConfirm: @escaping () -> Void = {},
                           onCancel: @escaping () -> Void = {}) {
        let command = Command(title: title, message: message, actions: ["Confirm": onConfirm, "Close": onCancel])
        showAlert(command)
    }

    func showConfirmChange(_ title: String,
                           message: String,
                           onConfirm: @escaping () -> Void = {},
                           onChange: @escaping () -> Void = {}) {
        let command = Command(title: title, message: message, actions: ["Confirm": onConfirm, "Change": onChange])
        showAlert(command)
    }

    func showOkChange(_ title: String,
                      message: String,
                      onOk: @escaping () -> Void = {},
                      onChange: @escaping () -> Void = {}) {
        let command = Command(title: title, message: message, actions: ["Ok": onOk, "Change": onChange])
        showAlert(command)
    }

    func showLetsgoLater(_ title: String,
                         message: String,
                         onLetsGo: @escaping () -> Void = {},
                         onLater: @escaping () -> Void = {}) {
        let command = Command(title: title, message: message, actions: ["Go": onLetsGo, "Later": onLater])
        showAlert(command)
    }

    func showOkNo(_ title: String,
                  message: String,
                  onOk: @escaping () -> Void = {},
                  onNo: @escaping () -> Void = {}) {
        let command = Command(title: title, message: message, actions: ["Ok": onOk, "No": onNo])
        showAlert(command)
    }

    private func showAlert(_ command: Command) {
        popupWindow.isHidden = false
        let alert = UIAlertController(title: command.title, message: command.message, preferredStyle: UIAlertController.Style.alert)
        for (title, action) in command.actions {
            let alertAction = UIAlertAction(title: title, style: UIAlertAction.Style.default, handler: { _ in
                self.popupWindow.isHidden = true
                action()
            })
            alert.addAction(alertAction)
        }
        rootVC.present(alert, animated: true, completion: nil)
    }
}
