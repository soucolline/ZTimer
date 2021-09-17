//
//  Theme.swift
//  ZTimer
//
//  Created by Thomas Guilleminot on 19/07/2021.
//  Copyright © 2021 Thomas Guilleminot. All rights reserved.
//

import Foundation
import UIKit

extension R {
    struct font {
        static func bold(size: CGFloat) -> UIFont {
            UIFont(name: "Avenir-Medium", size: size)!
        }

        static func light(size: CGFloat) -> UIFont {
            UIFont(name: "Avenir-Light", size: size)!
        }

        static func regular(size: CGFloat) -> UIFont {
            UIFont(name: "Avenir-Book", size: size)!
        }
    }
}
