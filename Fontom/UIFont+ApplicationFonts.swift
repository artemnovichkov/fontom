//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit

enum FontWeight: String {
    case bold
    case regular
    case medium
}

extension FontWeight {

    var weight: UIFont.Weight {
        switch self {
        case .bold:      return .bold
        case .regular:   return .regular
        case .medium:    return .medium
        }
    }
}

extension UIFont {
    
    static func sfProTextFont(ofSize size: CGFloat, weight: FontWeight) -> UIFont {
        let name: String
        switch weight {
        case .regular:
            name = "SFProText-Regular"
        case .bold:
            name = "SFProText-Bold"
        case .medium:
            name = "SFProText-Medium"
        }
        return UIFont(name: name, size: size)!
    }
}
