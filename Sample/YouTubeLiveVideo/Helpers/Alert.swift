import UIKit

class Alert: NSObject {

    var popupWindow: UIWindow!
    var rootVC: UIViewController!

    class var sharedInstance: Alert {
        struct SingletonWrapper {
            static let sharedInstance = Alert()
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
            self.resignPopupWindow()
            onComplete()
        }))

        rootVC.present(alert, animated: true, completion: nil)
    }

    func showOkCancel(_ title: String, message: String, onComplete: (() -> Void)?, onCancel: (() -> Void)?) {
        popupWindow.isHidden = false
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
            self.resignPopupWindow()
            onComplete?()
        })
        let cancelAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler: { _ in
            self.resignPopupWindow()
            onCancel?()
        })
        alert.addAction(cancelAction)
        alert.addAction(okAction)

        rootVC.present(alert, animated: true, completion: nil)
    }

    func showYesNo(_ title: String, message: String, onYes: @escaping () -> Void = {}, onNo: @escaping () -> Void = {}) {
        popupWindow.isHidden = false
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { _ in
            self.resignPopupWindow()
            onYes()
        })
        let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: { _ in
            self.resignPopupWindow()
            onNo()
        })
        alert.addAction(cancelAction)
        alert.addAction(okAction)

        rootVC.present(alert, animated: true, completion: nil)
    }

    func showConfirmCancel(_ title: String, message: String, onConfirm: @escaping () -> Void = {}, onCancel: @escaping () -> Void = {}) {
        popupWindow.isHidden = false
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Conform", style: UIAlertAction.Style.default, handler: { _ in
            self.resignPopupWindow()
            onConfirm()
        })
        let cancelAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: { _ in
            self.resignPopupWindow()
            onCancel()
        })
        alert.addAction(cancelAction)
        alert.addAction(okAction)

        rootVC.present(alert, animated: true, completion: nil)
    }

    func showConfirmChange(_ title: String, message: String, onConfirm: @escaping () -> Void = {}, onChange: @escaping () -> Void = {}) {
        popupWindow.isHidden = false
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Conform", style: UIAlertAction.Style.default, handler: { _ in
            self.resignPopupWindow()
            onConfirm()
        })
        let cancelAction = UIAlertAction(title: "Change", style: UIAlertAction.Style.default, handler: { _ in
            self.resignPopupWindow()
            onChange()
        })
        alert.addAction(cancelAction)
        alert.addAction(okAction)

        rootVC.present(alert, animated: true, completion: nil)
    }

    func showOkChange(_ title: String, message: String, onOk: @escaping () -> Void = {}, onChange: @escaping () -> Void = {}) {
        popupWindow.isHidden = false
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
            self.resignPopupWindow()
            onOk()
        })
        let cancelAction = UIAlertAction(title: "Change", style: UIAlertAction.Style.default, handler: { _ in
            self.resignPopupWindow()
            onChange()
        })
        alert.addAction(cancelAction)
        alert.addAction(okAction)

        rootVC.present(alert, animated: true, completion: nil)
    }

    func showLetsgoLater(_ title: String, message: String, onLetsGo: @escaping () -> Void = {}, onLater: @escaping () -> Void = {}) {
        popupWindow.isHidden = false
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let letsGoAction = UIAlertAction(title: "Go", style: UIAlertAction.Style.default, handler: { _ in
            self.resignPopupWindow()
            onLetsGo()
        })
        let laterAction = UIAlertAction(title: "Later", style: UIAlertAction.Style.default, handler: { _ in
            self.resignPopupWindow()
            onLater()
        })
        alert.addAction(laterAction)
        alert.addAction(letsGoAction)

        rootVC.present(alert, animated: true, completion: nil)
    }

    func showOkNo(_ title: String, message: String, onOk: @escaping () -> Void = {}, onNo: @escaping () -> Void = {}) {
        popupWindow.isHidden = false
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let letsGoAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
            self.resignPopupWindow()
            onOk()
        })
        let laterAction = UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: { _ in
            self.resignPopupWindow()
            onNo()
        })
        alert.addAction(laterAction)
        alert.addAction(letsGoAction)

        rootVC.present(alert, animated: true, completion: nil)
    }

    func resignPopupWindow() {
        self.popupWindow.isHidden = true
    }
}
