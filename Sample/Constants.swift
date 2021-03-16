//
//  Constants.swift
//  LiveEvents
//

import UIKit

struct Constants {
    private init() {}
}

extension Constants {

    static let kAppName = "Live Events"

    enum UiConstraints {
        static let debounce: Int = 300  // Milliseconds
    }
}

// MARK: - Colors

extension UIColor {
    static var darkblue: UIColor { #colorLiteral(red: 0.1083853021, green: 0.2324672937, blue: 0.3623062968, alpha: 1) }
    static var orange: UIColor { #colorLiteral(red: 0.9050243497, green: 0.5463837981, blue: 0.1405682266, alpha: 1) }
    static var contactsSeparator: UIColor { #colorLiteral(red: 0.8235294118, green: 0.8235294118, blue: 0.8235294118, alpha: 1) }
}
