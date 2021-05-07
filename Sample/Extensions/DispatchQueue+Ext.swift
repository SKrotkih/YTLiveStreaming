import Foundation

extension DispatchQueue {
	/// A list of dispatch tokens to track which have been called once.
	private static var _onceTracker = [String]()

	/**
	 Executes a block of code, associated with a unique token, only once.
	 The code is thread safe and will only execute the block once even in the presence of multithreaded calls.

	 Source:
	 https://stackoverflow.com/questions/37886994/dispatch-once-after-the-swift-3-gcd-api-changes

	 - parameter token: A unique token as key for the block.
	 Use a unique reverse DNS style name such as com.vectorform.<name> or a GUID.
	 - parameter block: Block to execute once.
	 */
	public class func once(token: String, block: () -> Void) {
		objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }

		if _onceTracker.contains(token) {
			return
		}

		_onceTracker.append(token)
		block()
	}

	/**
	 Executes a closure on the main tread.
     If the code is already executing on the main thread the closure will
     be executed synchronously, otherwise asynchronously.
	 - parameter closure: The closure to execute on the main thread mainly to update the UI.
	 */
	public class func performUIUpdate(using closure: @escaping () -> Void) {
		if Thread.isMainThread {
			closure()
		} else {
			main.async(execute: closure)
		}
	}
}
