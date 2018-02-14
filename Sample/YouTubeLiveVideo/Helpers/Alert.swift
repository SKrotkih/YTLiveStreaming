import UIKit

class Alert: NSObject {
    
    var popupWindow : UIWindow!
    var rootVC : UIViewController!

    class var sharedInstance: Alert {
        struct SingletonWrapper {
            static let sharedInstance = Alert()
        }
        
        return SingletonWrapper.sharedInstance;
    }
    
    fileprivate override init() {
        let screenBounds = UIScreen.main.bounds
        popupWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: screenBounds.width, height: screenBounds.height))
        popupWindow.windowLevel = UIWindowLevelStatusBar + 1
        
        rootVC = StatusBarShowingViewController()
        popupWindow.rootViewController = rootVC
        
        super.init()
    }

    func showOk(_ title: String, message: String, onComplete: @escaping ()->Void = {  }) {
        popupWindow.isHidden = false
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { _ in
            self.resignPopupWindow()
            onComplete()
        }))
        
        rootVC.present(alert, animated: true, completion: nil)
    }
    
    func showOkCancel(_ title: String, message: String, onComplete: (()->Void)?, onCancel: (()->Void)?) {
        popupWindow.isHidden = false
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { _ in
            self.resignPopupWindow()
            onComplete?()
        })
        let cancelAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel, handler: { _ in
            self.resignPopupWindow()
            onCancel?()
        })
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        rootVC.present(alert, animated: true, completion: nil)
    }
    
    func showYesNo(_ title: String, message: String, onYes: @escaping ()->Void = {}, onNo: @escaping ()->Void = {}) {
        popupWindow.isHidden = false
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { _ in
            self.resignPopupWindow()
            onYes()
        })
        let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: { _ in
            self.resignPopupWindow()
            onNo()
        })
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        rootVC.present(alert, animated: true, completion: nil)
    }
    
    func showConfirmCancel(_ title: String, message: String, onConfirm: @escaping ()->Void = {}, onCancel: @escaping ()->Void = {}) {
        popupWindow.isHidden = false
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Conform", style: UIAlertActionStyle.default, handler: { _ in
            self.resignPopupWindow()
            onConfirm()
        })
        let cancelAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: { _ in
            self.resignPopupWindow()
            onCancel()
        })
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        rootVC.present(alert, animated: true, completion: nil)
    }
    
    func showConfirmChange(_ title: String, message: String, onConfirm: @escaping ()->Void = {}, onChange: @escaping ()->Void = {}) {
        popupWindow.isHidden = false
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Conform", style: UIAlertActionStyle.default, handler: { _ in
            self.resignPopupWindow()
            onConfirm()
        })
        let cancelAction = UIAlertAction(title: "Change", style: UIAlertActionStyle.default, handler: { _ in
            self.resignPopupWindow()
            onChange()
        })
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        rootVC.present(alert, animated: true, completion: nil)
    }
    
    func showOkChange(_ title: String, message: String, onOk: @escaping ()->Void = {}, onChange: @escaping ()->Void = {}) {
        popupWindow.isHidden = false
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { _ in
            self.resignPopupWindow()
            onOk()
        })
        let cancelAction = UIAlertAction(title: "Change", style: UIAlertActionStyle.default, handler: { _ in
            self.resignPopupWindow()
            onChange()
        })
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        rootVC.present(alert, animated: true, completion: nil)
    }
    
    func showLetsgoLater(_ title: String, message: String, onLetsGo: @escaping ()->Void = {}, onLater: @escaping ()->Void = {}) {
        popupWindow.isHidden = false
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let letsGoAction = UIAlertAction(title: "Go", style: UIAlertActionStyle.default, handler: { _ in
            self.resignPopupWindow()
            onLetsGo()
        })
        let laterAction = UIAlertAction(title: "Later", style: UIAlertActionStyle.default, handler: { _ in
            self.resignPopupWindow()
            onLater()
        })
        alert.addAction(laterAction)
        alert.addAction(letsGoAction)
        
        rootVC.present(alert, animated: true, completion: nil)
    }
    
    func showOkNo(_ title: String, message: String, onOk: @escaping ()->Void = {}, onNo: @escaping ()->Void = {}) {
        popupWindow.isHidden = false
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let letsGoAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { _ in
            self.resignPopupWindow()
            onOk()
        })
        let laterAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: { _ in
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
